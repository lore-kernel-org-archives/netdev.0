From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: linux-next: manual merge of the net tree with Linus' tree
Date: Mon, 17 Oct 2016 11:41:49 +0000
Message-ID: <BL2PR07MB2306E247793F8600405A6E238DD00@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20161016081317.229c5c47@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Amrani, Ram" <Ram.Amrani@cavium.com>,
        Doug Ledford <dledford@redhat.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0059.outbound.protection.outlook.com ([104.47.38.59]:5427
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933852AbcJQLlw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 07:41:52 -0400
In-Reply-To: <20161016081317.229c5c47@canb.auug.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Today's linux-next merge of the net tree got a conflict in:

> =A0 drivers/net/ethernet/qlogic/Kconfig

> between commit:

> =A0 2e0cbc4dd077 ("qedr: Add RoCE driver framework")

> from Linus' tree and commit:

> =A0 0189efb8f4f8 ("qed*: Fix Kconfig dependencies with INFINIBAND_QEDR")

> from the net tree.

> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.=A0=20

My bad; I've sent the fix to 'net' and was not aware that the
qedr submission was already accepted in linux-rdma.

> I also added this merge fix patch:

> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Sun, 16 Oct 2016 08:09:42 +1100
> Subject: [PATCH] qed*: merge fix for CONFIG_INFINIBAND_QEDR Kconfig move

> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
> =A0drivers/infiniband/hw/qedr/Kconfig | 1 +
> =A01 file changed, 1 insertion(+)

> diff --git a/drivers/infiniband/hw/qedr/Kconfig b/drivers/infiniband/hw/q=
edr/Kconfig
> index 7c06d85568d4..6c9f3923e838 100644
> --- a/drivers/infiniband/hw/qedr/Kconfig
> +++ b/drivers/infiniband/hw/qedr/Kconfig
> @@ -2,6 +2,7 @@ config INFINIBAND_QEDR
> =A0=A0=A0=A0=A0=A0=A0=A0 tristate "QLogic RoCE driver"
> =A0=A0=A0=A0=A0=A0=A0=A0 depends on 64BIT && QEDE
> =A0=A0=A0=A0=A0=A0=A0=A0 select QED_LL2
> +=A0=A0=A0=A0=A0=A0 select QED_RDMA
> =A0=A0=A0=A0=A0=A0=A0=A0 ---help---
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 This driver provides low-level InfiniBand =
over Ethernet
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 support for QLogic QED host channel adapte=
rs (HCAs).
> --=20
> 2.8.1

Looks good; Thanks.=

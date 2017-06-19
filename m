From: "Kalderon, Michal" <Michal.Kalderon@cavium.com>
Subject: RE: [PATCH v2 net-next 0/7] qed*: RDMA and infrastructure for iWARP
Date: Mon, 19 Jun 2017 06:28:53 +0000
Message-ID: <DM2PR0701MB1392C0D6A29561095E40891288C40@DM2PR0701MB1392.namprd07.prod.outlook.com>
References: <20170618115035.2156-1-Yuval.Mintz@cavium.com>
 <20170618131443.GA27458@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0048.outbound.protection.outlook.com ([104.47.38.48]:15536
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751875AbdFSG24 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Jun 2017 02:28:56 -0400
In-Reply-To: <20170618131443.GA27458@infradead.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig [mailto:hch@infradead.org]
Sent: Sunday, June 18, 2017 4:15 PM
=20
> On Sun, Jun 18, 2017 at 02:50:28PM +0300, Yuval Mintz wrote:
> > This series focuses on RDMA in general with emphasis on required
> > changes toward adding iWARP support. The vast majority of the changes
> > introduced are in qed/qede, with a couple of small changes to qedr
> > [mentioned below].
>=20
> Btw, can you explain us how you are going to expose RoCE vs iWarp?
> Is it going to be a per-port setting?  Are you going to use different ib_=
device
> structures or do you plan to differenciate at another level?

Initial submission will be based on iWARP or RoCE being part of the device =
configuration ( using EFI-Hii),=20
Later on we're considering adding devlink support for changing the device c=
onfiguration.
This is not a port setting, pci devices sharing the same physical port can =
have different RDMA protocols.

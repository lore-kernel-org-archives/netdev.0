From: "Mody, Rasesh" <Rasesh.Mody@cavium.com>
Subject: RE: [PATCH] net: brocade: bna: use new api
 ethtool_{get|set}_link_ksettings
Date: Tue, 29 Nov 2016 07:37:30 +0000
Message-ID: <BLUPR0701MB15722780A1592E3BCA65E8AD9F8D0@BLUPR0701MB1572.namprd07.prod.outlook.com>
References: <1480373539-3257-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>,
        Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0069.outbound.protection.outlook.com ([104.47.40.69]:12800
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752046AbcK2Hhd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 02:37:33 -0500
In-Reply-To: <1480373539-3257-1-git-send-email-tremyfr@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Philippe Reynes [mailto:tremyfr@gmail.com]
> Sent: Monday, November 28, 2016 2:52 PM
>=20
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
>=20
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Acked-by: Rasesh Mody <Rasesh.Mody@cavium.com>=20

> ---
>  drivers/net/ethernet/brocade/bna/bnad_ethtool.c |   54 +++++++++++++--
> --------
>  1 files changed, 30 insertions(+), 24 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
> b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
> index 31f61a7..2865939 100644
> --- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
> +++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c

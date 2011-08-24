From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH 1/2] bnx2x: resurrect RX hashing
Date: Wed, 24 Aug 2011 14:18:32 +0300
Message-ID: <201108241418.32356.vladz@broadcom.com>
References: <20110823161530.24707.67923.stgit@dhcp-29-224.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	=?utf-8?q?Micha=C5=82Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1957 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756441Ab1HXLSt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 07:18:49 -0400
In-Reply-To: <20110823161530.24707.67923.stgit@dhcp-29-224.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 23 August 2011 19:15:32 Michal Schmidt wrote:
> bnx2x used to be able to set rxhash, but this was lost in the convers=
ion
> to hw_features (commit 66371c441).
> Restore it and enable it by default.
>=20
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> CC: Vladislav Zolotarov <vladz@broadcom.com>
> CC: Eilon Greenstein <eilong@broadcom.com>
> CC: Dmitry Kravkov <dmitry@broadcom.com>
> CC: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>=20
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c index 7204789..85d=
d294
> 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -10285,8 +10285,8 @@ static int __devinit bnx2x_init_dev(struct pc=
i_dev
> *pdev, dev->priv_flags |=3D IFF_UNICAST_FLT;
>=20
>  	dev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CS=
UM |
> -		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
> -		NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_HW_VLAN_TX;
> +		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_LRO |
> +		NETIF_F_RXCSUM | NETIF_F_RXHASH | NETIF_F_HW_VLAN_TX;
>=20
>  	dev->vlan_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_=
CSUM |
>  		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA;

ACK

Thanks, Michal.

vlad

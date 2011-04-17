From: <Ajit.Khaparde@Emulex.Com>
Subject: RE: [PATCH] net: benet: convert to hw_features - fixup
Date: Sun, 17 Apr 2011 09:14:19 -0700
Message-ID: <2146097c-f310-4cf8-8b78-a9b150d6482d@exht2.ad.emulex.com>
References: <20110417101547.5F75513A6A@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <Sathya.Perla@Emulex.Com>, <subbu.seetharaman@emulex.com>
To: <mirq-linux@rere.qmqm.pl>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:2806 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750853Ab1DQQRh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 12:17:37 -0400
In-Reply-To: <20110417101547.5F75513A6A@rere.qmqm.pl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Remove be_set_flags() as it's already covered by hw_features.

> Signed-off-by: Micha=B3 Miros=B3aw mirq-linux@rere.qmqm.pl
Acked-by: Ajit Khaparde ajit.khaparde@emulex.com

> ---
>  drivers/net/benet/be_ethtool.c |   13 -------------
>  1 files changed, 0 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_et=
htool.c
> index 80226e4..ab7ebdd 100644
> --- a/drivers/net/benet/be_ethtool.c
> +++ b/drivers/net/benet/be_ethtool.c
> @@ -716,18 +716,6 @@ be_read_eeprom(struct net_device *netdev, struct=
 ethtool_eeprom *eeprom,
>         return status;
>  }

> -static int be_set_flags(struct net_device *netdev, u32 data)
> -{
> -       struct be_adapter *adapter =3D netdev_priv(netdev);
> -       int rc =3D -1;
> -
> -       if (be_multi_rxq(adapter))
> -               rc =3D ethtool_op_set_flags(netdev, data, ETH_FLAG_RX=
HASH |
> -                               ETH_FLAG_TXVLAN | ETH_FLAG_RXVLAN);
> -
> -       return rc;
> -}
> -
>  const struct ethtool_ops be_ethtool_ops =3D {
>         .get_settings =3D be_get_settings,
>         .get_drvinfo =3D be_get_drvinfo,
> @@ -749,5 +737,4 @@ const struct ethtool_ops be_ethtool_ops =3D {
>         .get_regs =3D be_get_regs,
>         .flash_device =3D be_do_flash,
>         .self_test =3D be_self_test,
> -       .set_flags =3D be_set_flags,
>  };
> --
> 1.7.2.5
>
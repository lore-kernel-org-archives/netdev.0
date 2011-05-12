From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 14/15] ehea: Add GRO support
Date: Thu, 12 May 2011 08:03:46 +0200
Message-ID: <BANLkTimUDAGdz2YmZKKvUpYYp+GchTd+8A@mail.gmail.com>
References: <20110512005213.897432612@samba.org> <20110512005623.766530798@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com, netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:63211 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755149Ab1ELGEG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 02:04:06 -0400
Received: by qyk7 with SMTP id 7so2726623qyk.19
        for <netdev@vger.kernel.org>; Wed, 11 May 2011 23:04:06 -0700 (PDT)
In-Reply-To: <20110512005623.766530798@samba.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/12 Anton Blanchard <anton@samba.org>:
> Add GRO support to the ehea driver.
[...]
> --- linux-net.orig/drivers/net/ehea/ehea_main.c 2011-05-12 07:48:03.8=
10341336 +1000
> +++ linux-net/drivers/net/ehea/ehea_main.c =C2=A0 =C2=A0 =C2=A02011-0=
5-12 07:48:05.100361788 +1000
[...]
> @@ -3041,7 +3034,7 @@ struct ehea_port *ehea_setup_single_port
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->netdev_ops =3D &ehea_netdev_ops;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ehea_set_ethtool_ops(dev);
>
> - =C2=A0 =C2=A0 =C2=A0 dev->hw_features =3D NETIF_F_SG | NETIF_F_TSO
> + =C2=A0 =C2=A0 =C2=A0 dev->hw_features =3D NETIF_F_SG | NETIF_F_TSO =
| NETIF_F_GRO
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0| NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX | NETIF_F_LRO;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->features =3D NETIF_F_SG | NETIF_F_FRA=
GLIST | NETIF_F_TSO
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0| NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX

GRO is now enabled by default, so no need to put it in hw_features or f=
eatures.

Best Regards,
Micha=C5=82 Miros=C5=82aw

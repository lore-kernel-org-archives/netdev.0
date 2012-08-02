From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/4] net/mlx4_en: Setting the NETIF_F_GRO flag back to dev->hw_features
Date: Thu, 2 Aug 2012 21:36:32 +0200
Message-ID: <CAHXqBF+EEqBUE_pP7h7+fSmgkxdUN0O=QME4Y=_7OxoBSp6sqg@mail.gmail.com>
References: <1343921456-19180-1-git-send-email-yevgenyp@mellanox.co.il> <1343921456-19180-2-git-send-email-yevgenyp@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:40642 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752398Ab2HBTgx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 15:36:53 -0400
Received: by vbbff1 with SMTP id ff1so8513265vbb.19
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2012 12:36:53 -0700 (PDT)
In-Reply-To: <1343921456-19180-2-git-send-email-yevgenyp@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/8/2 Yevgeny Petrilin <yevgenyp@mellanox.co.il>:
> The bug which removed it was introduced in commit c8c64cff
> which added the hw_features.
[...]
> -       dev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_I=
PV6_CSUM;
> +       dev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_I=
PV6_CSUM |
> +                          NETIF_F_GRO;

Just try to realize the truth: there is no bug.

register_netdevice() is setting GSO and GRO bits for everyone.

Best Regards,
Micha=C5=82 Miros=C5=82aw

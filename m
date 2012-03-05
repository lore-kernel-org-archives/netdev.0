From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] 8139too: Add 64bit statistics
Date: Mon, 05 Mar 2012 05:32:06 -0800
Message-ID: <1330954326.2474.9.camel@edumazet-laptop>
References: <20120305113353.GA12969@Spy32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, greearb@candelatech.com, adobriyan@gmail.com,
	jasowang@redhat.com, joe@perches.com, netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:47401 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932213Ab2CENcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 08:32:09 -0500
Received: by dadp12 with SMTP id p12so5109766dad.11
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 05:32:09 -0800 (PST)
In-Reply-To: <20120305113353.GA12969@Spy32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 mars 2012 =C3=A0 19:33 +0800, Junchang Wang a =C3=A9crit :
> Switch to use ndo_get_stats64 to get 64bit statistics.
> Two sync entries are used (one for Rx and one for Tx).
>=20
> Signed-off-by: Junchang Wang <junchangwang@gmail.com>
> ---

=2E..

> +	stats->rx_errors	=3D dev->stats.rx_errors;
> +	stats->tx_errors	=3D dev->stats.tx_errors;
> +	stats->rx_dropped	=3D dev->stats.rx_dropped;
> +	stats->tx_dropped	=3D dev->stats.tx_dropped;
> +	stats->collisions	=3D dev->stats.collisions;
> +
> +	stats->rx_length_errors =3D dev->stats.rx_length_errors;
> +	stats->rx_crc_errors	=3D dev->stats.rx_crc_errors;
> +	stats->rx_frame_errors	=3D dev->stats.rx_frame_errors;
> +	stats->rx_fifo_errors	=3D dev->stats.rx_fifo_errors;
> +	stats->rx_missed_errors	=3D dev->stats.rx_missed_errors;
> +
> +	stats->tx_aborted_errors =3D dev->stats.tx_aborted_errors;
> +	stats->tx_carrier_errors =3D dev->stats.tx_carrier_errors;
> +	stats->tx_fifo_errors	=3D dev->stats.tx_fifo_errors;
> +	stats->tx_window_errors =3D dev->stats.tx_window_errors;
> +
> +	return stats;
>  }
> =20

Maybe its time to export netdev_stats_to_stats64() after all, to avoid
all this duplicate code.

I'll submit a patch.

Could you repost this after netdev_stats_to_stats64() being available t=
o
drivers ?

Thanks

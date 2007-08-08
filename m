From: David Miller <davem@davemloft.net>
Subject: Re: TCP's initial cwnd setting correct?...
Date: Tue, 07 Aug 2007 18:28:23 -0700 (PDT)
Message-ID: <20070807.182823.123919803.davem@davemloft.net>
References: <Pine.LNX.4.64.0708061508070.8788@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58149
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758172AbXHHB2X convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 21:28:23 -0400
In-Reply-To: <Pine.LNX.4.64.0708061508070.8788@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 6 Aug 2007 15:37:15 +0300 (EEST)

> @@ -805,13 +805,13 @@ void tcp_update_metrics(struct sock *sk)
>  	}
>  }
> =20
> -/* Numbers are taken from RFC2414.  */
> +/* Numbers are taken from RFC3390.  */
>  __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst)
>  {
>  	__u32 cwnd =3D (dst ? dst_metric(dst, RTAX_INITCWND) : 0);
> =20
>  	if (!cwnd) {
> -		if (tp->mss_cache > 1460)
> +		if (tp->mss_cache >=3D 2190)
>  			cwnd =3D 2;
>  		else
>  			cwnd =3D (tp->mss_cache > 1095) ? 3 : 4;

I remember suggesting something similar about 5 or 6 years
ago and Alexey Kuznetsov at the time explained the numbers
which are there and why they should not be changed.

I forget the reasons though, and I'll try to do the research.

These numbers have been like this forever, FWIW.

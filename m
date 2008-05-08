From: David Miller <davem@davemloft.net>
Subject: Re: Fix FRTO+NewReno problem
Date: Thu, 08 May 2008 01:10:21 -0700 (PDT)
Message-ID: <20080508.011021.14498289.davem@davemloft.net>
References: <Pine.LNX.4.64.0805061912350.8965@wrl-59.cs.helsinki.fi>
	<4821C37A.7040306@damtek.com>
	<Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: damon@damtek.com, 213081@bugs.launchpad.net,
	478062@bugs.debian.org, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50500
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751453AbYEHIK2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 04:10:28 -0400
In-Reply-To: <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 8 May 2008 01:26:59 +0300 (EEST)

> [PATCH] [TCP] FRTO: SACK variant is errorneously used with NewReno

I applied this with a minor coding style fixup.

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 8 May 2008 01:26:59 +0300 (EEST)

> +static int tcp_is_sackfrto(const struct tcp_sock *tp) {
> +	return (sysctl_tcp_frto =3D=3D 0x2) && !tcp_is_reno(tp);
> +}
> +

Should be:

static int tcp_is_sackfrto(const struct tcp_sock *tp)
{
	return (sysctl_tcp_frto =3D=3D 0x2) && !tcp_is_reno(tp);
}

I will also queue this up to -stable, thanks so much for
this bug fix!

From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Thu, 3 Dec 2009 09:59:33 +0100
Message-ID: <20091203085933.GD30730@sd-11162.dedibox.fr>
References: <20091130213727.2f4047d2@houba> <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi> <20091201211945.505d3c98@houba> <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi> <20091202085925.472136e2@houba> <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi> <20091202154403.GB30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi> <20091202183451.173db5f2@houba> <4B16BD58.3040802@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:32924 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbZLCI71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 03:59:27 -0500
Content-Disposition: inline
In-Reply-To: <4B16BD58.3040802@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 02, 2009 at 08:17:44PM +0100, Damian Lukowski wrote:
> could you please printk retrans_stamp just before the return in=20
> include/net/tcp.h:retransmits_timed_out()?
> If the value is not monotonically increasing but is reset to 0 at som=
e
> point, this might lead to problems in tcp_write_timeout().
> It's the only idea I have now.

Your idea is good.
Only one out of 4 value is not null.

Logs corresponding on http://wwW.starox.org/pub/scp_stall is .10

I make 2 attempts. Printk corresponding to .10 are those after the line=
=20
"wlan1 enter promiscuous mode"

--=20
=46r=E9d=E9ric Leroy

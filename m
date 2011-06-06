From: Rick Jones <rick.jones2@hp.com>
Subject: Re: small RPS cache for fragments?
Date: Mon, 06 Jun 2011 11:06:19 -0700
Message-ID: <1307383579.8149.2753.camel@tardy>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	 <20110524.160123.2051949867829317339.davem@davemloft.net>
	 <1306273128.8149.1444.camel@tardy>
	 <20110604.132940.2214949964968775365.davem@davemloft.net>
	 <1307380132.8149.2718.camel@tardy>
	 <1307380513.3098.76.camel@edumazet-laptop>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:17534 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756286Ab1FFSGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 14:06:24 -0400
In-Reply-To: <1307380513.3098.76.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-06 at 19:15 +0200, Eric Dumazet wrote:
> Le lundi 06 juin 2011 =C3=A0 10:08 -0700, Rick Jones a =C3=A9crit :
>=20
> > Mode-rr bonding reorders TCP segments all the time.=20
>=20
> Shouldnt TCP frames have DF bit set ?

I was ass-u-me-ing that when talking about TCP, David was speaking
generally about TCP segments, and suggesting that were bonding's mode-r=
r
altered to not re-order TCP segments, a similar technique
could/would/should avoid re-ordering IP datagram fragments, regardless
of their payload.

Jay will have to weigh-in on how difficult that would be, I'm guessing
it would mean a fair bit of overhead to mode-rr though, to know the
completion status of frames from the same flow and/or the depth of the
tx queues etc etc.  I thought that one of mode-rr's (few IMO, just chec=
k
the archives where I've complained about it :) redeeming qualities was
its minimal overhead.

rick jones


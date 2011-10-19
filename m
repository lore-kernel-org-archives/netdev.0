From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 15:57:18 +0200
Message-ID: <1319032638.1286.7.camel@jlt3.sipsolutions.net>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
	 <cover.1318498805.git.richard.cochran@omicron.at>
	 <20111019.001610.312990203017422173.davem@davemloft.net>
	 <1319001336.4424.8.camel@jlt3.sipsolutions.net>
	 <20111019115012.GA7206@netboy.at.omicron.at>
	 <1319027881.3103.27.camel@edumazet-laptop>
	 (sfid-20111019_143837_360206_014A6AA4)  <1319029101.4424.36.camel@jlt3.sipsolutions.net>
	 <1319029794.4424.37.camel@jlt3.sipsolutions.net>
	 <1319030740.8416.14.camel@edumazet-laptop>
	 (sfid-20111019_152616_037809_8B36A3CC) <1319031348.1286.4.camel@jlt3.sipsolutions.net>
	 <1319031856.8416.19.camel@edumazet-laptop>
	 (sfid-20111019_154501_303541_A1FD5289)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:38863 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159Ab1JSN5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 09:57:22 -0400
In-Reply-To: <1319031856.8416.19.camel@edumazet-laptop> (sfid-20111019_154501_303541_A1FD5289)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-19 at 15:44 +0200, Eric Dumazet wrote:
> Le mercredi 19 octobre 2011 =C3=A0 15:35 +0200, Johannes Berg a =C3=A9=
crit :
>=20
> > Even with that fixed I'm not really convinced of it all -- need to
> > really really really make sure that no skb->sk that was owned by a =
TX
> > skb is ever passed to sock_hold(). Can we really guarantee that?
>=20
> Either we can guarantee that, or kernel is a piece of crap, all bets =
are
> off.

=46air enough :-)

> Yes, we need to make an audit, since we assumed sock_hold() was the
> right thing to do in all contexts.

Ok.

Anyway, I guess you agree that the patches as-is aren't actually the
right solution since we can't sock_hold() a TX skb socket reference?

johannes

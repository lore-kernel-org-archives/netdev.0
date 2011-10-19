From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 15:32:53 +0200
Message-ID: <1319031173.1286.1.camel@jlt3.sipsolutions.net>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
	 <cover.1318498805.git.richard.cochran@omicron.at>
	 <20111019.001610.312990203017422173.davem@davemloft.net>
	 <1319001336.4424.8.camel@jlt3.sipsolutions.net>
	 <20111019115012.GA7206@netboy.at.omicron.at>
	 <1319027881.3103.27.camel@edumazet-laptop>
	 (sfid-20111019_143837_360206_014A6AA4) <1319029101.4424.36.camel@jlt3.sipsolutions.net>
	 <1319030503.8416.11.camel@edumazet-laptop>
	 (sfid-20111019_152225_494986_6CAEF901) <1319030738.4424.39.camel@jlt3.sipsolutions.net>
	 <1319030829.8416.15.camel@edumazet-laptop>
	 (sfid-20111019_152744_297798_F3FFFAC9)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:46072 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597Ab1JSNc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 09:32:58 -0400
In-Reply-To: <1319030829.8416.15.camel@edumazet-laptop> (sfid-20111019_152744_297798_F3FFFAC9)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-19 at 15:27 +0200, Eric Dumazet wrote:
> Le mercredi 19 octobre 2011 =C3=A0 15:25 +0200, Johannes Berg a =C3=A9=
crit :
>=20
> > Well, yeah, ok, but Richard's patches do modify sk_refcnt, and can'=
t
> > modify sk_wmem_alloc as discussed upthread.
> >=20
> > I'll admit that I don't really trust the whole thing anyway -- it s=
eems
> > rather error prone to forbid you from doing sock_hold() on a socket=
 you
> > obtained from a TX packet.
> >=20
>=20
> I probably missed why sk_wmem_alloc can not be modified ?

I think I misremember -- I was suggesting to set skb2->truesize to 1 an=
d
then charge it so it's not double-charged.

OTOH, could skb_clone_tx_timestamp() orphan the original skb after
adding the skb2?

johannes

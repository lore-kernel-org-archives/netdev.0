From: Simon Horman <horms@verge.net.au>
Subject: Re: bonding: flow control regression [was Re: bridging: flow
 control regression]
Date: Tue, 2 Nov 2010 16:03:11 +0900
Message-ID: <20101102070308.GA19924@verge.net.au>
References: <20101101122920.GB10052@verge.net.au>
 <1288616372.2660.101.camel@edumazet-laptop>
 <20101102020625.GA22724@verge.net.au>
 <1288673622.2660.147.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:54330 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753059Ab0KBHDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 03:03:25 -0400
Content-Disposition: inline
In-Reply-To: <1288673622.2660.147.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 02, 2010 at 05:53:42AM +0100, Eric Dumazet wrote:
> Le mardi 02 novembre 2010 =C3=A0 11:06 +0900, Simon Horman a =C3=A9cr=
it :
>=20
> > Thanks for the explanation.
> > I'm not entirely sure how much of a problem this is in practice.
>=20
> Maybe for virtual devices (tunnels, bonding, ...), it would make sens=
e
> to delay the orphaning up to the real device.

That was my initial thought. Could you give me some guidance
on how that might be done so I can try and make a patch to test?

> But if the socket send buffer is very large, it would defeat the flow
> control any way...

I'm primarily concerned about a situation where
UDP packets are sent as fast as possible, indefinitely.
And in that scenario, I think it would need to be a rather large buffer=
=2E


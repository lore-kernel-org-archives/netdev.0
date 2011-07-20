From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] skbuff: use kfree_skb() instead of kfree()
Date: Wed, 20 Jul 2011 10:21:24 +0200
Message-ID: <1311150084.2338.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110720072343.GF6445@shale.localdomain>
	 <20110720072549.GG6445@shale.localdomain>
	 <1311147723.3113.116.camel@edumazet-laptop>
	 <20110720080109.GH6445@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shirley Ma <xma@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55990 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885Ab1GTIVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 04:21:33 -0400
In-Reply-To: <20110720080109.GH6445@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 juillet 2011 =C3=A0 11:01 +0300, Dan Carpenter a =C3=A9c=
rit :
> On Wed, Jul 20, 2011 at 09:42:03AM +0200, Eric Dumazet wrote:
> > Le mercredi 20 juillet 2011 =C3=A0 10:25 +0300, Dan Carpenter a =C3=
=A9crit :
> > > Crap.  Sorry, I shouldn't have sent that.  We shouldn't return th=
e
> > > freed "n" here.  I'll send a v2 shortly.
> >=20
> > Also, dont forget to say its a patch for net-next-2.6
>=20
> If you're using linux-next, is there a way to tell which tree a
> patch came from?  Obviously in this case it's core networking, but
> in other cases how does that work?

In this particular case, David will know for sure since patch is very
recent, but I wanted to make a general advice.

Keep in mind David has to review dozens of patches _per_ day, so netdev
related patches need some extra cooperation from submitters to help the
maintainer.

This extra cooperation means to test the patch on either net-next-2.6 o=
r
net-2.6 tree ;)




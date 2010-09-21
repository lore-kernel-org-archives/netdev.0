From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression, bisected: reference leak with IPSec since ~2.6.31
Date: Tue, 21 Sep 2010 11:55:48 +0200
Message-ID: <1285062948.2617.204.camel@edumazet-laptop>
References: <20100921091248.GA8424@ff.dom.local>
	 <1285060860.2617.158.camel@edumazet-laptop>
	 <20100921093853.GA8664@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nick Bowler <nbowler@elliptictech.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100921093853.GA8664@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 21 septembre 2010 =C3=A0 09:38 +0000, Jarek Poplawski a =C3=A9=
crit :
> On Tue, Sep 21, 2010 at 11:21:00AM +0200, Eric Dumazet wrote:

> I hope you're right with this.
>=20
> >=20
> > I liked the :
> >=20
> > <check everything without changing state>
> > if something wrong
> > 	goto slow_path
> > else
> > 	<OK, lets do destructive things>
> >=20
>=20
> But it's an optimization of the "unlikely" case btw. ;-)
>=20

This is a bug fix, in a complex function.

in -next branch, we can try to be smart, adding more code in slow_path
to revert what was done in the hope fast path would be taken.
And pray we dont add another bug :)

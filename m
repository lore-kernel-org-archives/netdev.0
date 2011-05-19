From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel BUG at net/ipv4/tcp_output.c:1006!
Date: Thu, 19 May 2011 19:11:26 +0200
Message-ID: <1305825086.3028.84.camel@edumazet-laptop>
References: <1305307633.3866.61.camel@edumazet-laptop>
	 <4DCD86C0.9030904@techboom.com>	<1305316058.3120.6.camel@edumazet-laptop>
	 <20110513.160138.1477780250019480052.davem@davemloft.net>
	 <4DD54E89.7050707@techboom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: TB <lkml@techboom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DD54E89.7050707@techboom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 19 mai 2011 =C3=A0 13:08 -0400, TB a =C3=A9crit :
> On 11-05-13 04:01 PM, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Fri, 13 May 2011 21:47:38 +0200
> >=20
> >> I suspect we should push commit 2fceec13375e5d98 (tcp: len check i=
s
> >> unnecessarily devastating, change to WARN_ON) to stable if not alr=
eady
> >> done...
> >>
> >> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git=
;a=3Dcommitdiff;h=3D2fceec13375e5d98
> >>
> >> David, is this commit in your stable queue ?
> >=20
> > No, but now it is.
>=20
> We've put this commit with the previous tcp_cubic patch on 60 of our
> servers and we're waiting to see how it goes.

Dont expect too much. It only permits to survive after logging messages=
,
instead of halting machine ;)

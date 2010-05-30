From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Subject: [PATCH] net/ipv6: Use GFP_ATOMIC when a lock is held
Date: Sun, 30 May 2010 23:18:18 +0200
Message-ID: <1275254298.2472.26.camel@edumazet-laptop>
References: <Pine.LNX.4.64.1005302147310.19253@ask.diku.dk>
	 <1275250288.2472.21.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1005302248500.19253@ask.diku.dk>
	 <1275252912.2472.23.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1005302303180.19253@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1005302303180.19253@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 30 mai 2010 =C3=A0 23:09 +0200, Julia Lawall a =C3=A9crit :

> could exit with success without the kzalloc ever being called.  If th=
e=20
> kzalloc is moved up, it could fail and then it returns immediately wi=
thout=20
> executing the loop.  A solution could be to leave the NULL test on p =
where=20
> it is, and only move up the kzalloc.  Or perhaps the change in behavi=
or=20
> doesn't matter?

If a GFP_KERNEL allocation fails, we are in a big trouble anyway :)

GFP_ATOMIC are more problematic in this area :)

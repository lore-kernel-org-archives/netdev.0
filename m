From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Subject: [PATCH] net/ipv6: Use GFP_ATOMIC when a lock is held
Date: Sun, 30 May 2010 22:55:12 +0200
Message-ID: <1275252912.2472.23.camel@edumazet-laptop>
References: <Pine.LNX.4.64.1005302147310.19253@ask.diku.dk>
	 <1275250288.2472.21.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1005302248500.19253@ask.diku.dk>
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
In-Reply-To: <Pine.LNX.4.64.1005302248500.19253@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 30 mai 2010 =C3=A0 22:50 +0200, Julia Lawall a =C3=A9crit :

> I think the proposed patch does not work, because the for loop overwr=
ites=20
> p.  That use of p looks like it is completely local to the for loop, =
so=20
> perhaps a new variable p1 could be added to be used there?

Please do so.

I just wanted to tell you changing GFP_KERNEL to GFP_ATOMIC is not an
appropriate way to solve this kind of problems. My patch was to get an
idea, not a full and tested patch :)

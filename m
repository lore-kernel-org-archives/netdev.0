From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Add default_advmss() methods to blackhole dst_ops
Date: Fri, 18 Feb 2011 14:24:03 +0100
Message-ID: <1298035443.6201.51.camel@edumazet-laptop>
References: <20110218050321.10415.qmail@science.horizon.com>
	 <1298010735.2642.9.camel@edumazet-laptop>
	 <1298023023.2595.170.camel@edumazet-laptop>
	 <AANLkTi=GRPWNWZuORx1zoJJURE-drqEoMdTuKB9LZ8Ux@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: George Spelvin <linux@horizon.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Roland Dreier <roland@purestorage.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=GRPWNWZuORx1zoJJURE-drqEoMdTuKB9LZ8Ux@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 18 f=C3=A9vrier 2011 =C3=A0 21:16 +0800, Changli Gao a =C3=A9=
crit :

> I am wondering why magic number 256 is used here. Is there a special
> reason? Thanks.
>=20

It really doesnt matter. SYN message will be dropped anyway.

256 happens to be the default value
of /proc/sys/net/ipv4/route/min_adv_mss

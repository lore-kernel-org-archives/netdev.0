From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add netdev_alloc_skb_ip_align() helper
Date: Fri, 09 Oct 2009 20:43:12 -0700 (PDT)
Message-ID: <20091009.204312.130400631.davem@davemloft.net>
References: <4ACD585B.5080106@gmail.com>
	<20091007.224036.247820677.davem@davemloft.net>
	<4ACF6562.9040109@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: thomas@wytron.com.tw, netdev@vger.kernel.org,
	thierry.reding@avionic-design.de, nios2-dev@sopc.et.ntust.edu.tw,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754762AbZJJDnT@vger.kernel.org>
In-Reply-To: <4ACF6562.9040109@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 9 Oct 2009 18:31:30 +0200

> David Miller a =E9crit :
>=20
>> Looks ok, but I want to look at how often this exact sequence
>> would match.  If it applies to a lot of cases, I'll add this
>> but I know of many exceptions in my head already :-)
>=20
> Well, it was more as a reference. I believe about 20-30 call sites
> could use it. Do you want me to provide a combo patch ?

No, that's not necessary.

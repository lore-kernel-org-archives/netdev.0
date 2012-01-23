From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Mon, 23 Jan 2012 23:23:43 +0100
Message-ID: <CAGsizzJnQ6b6eSC0ZnAtFguU7_xDfWFPSY6L4DWXc24F+Ts2XQ@mail.gmail.com>
References: <3900291.2831326843194846.JavaMail.root@5-MeO-DMT.ynet.sk>
 <CAGsizzLUwA_=fZFX-4ZnYU4K-nj1A2DV_BZKOMKxgQDh2Rs54g@mail.gmail.com>
 <1327327999.2525.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20120123.134352.1621146585245670953.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120123.134352.1621146585245670953.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/1/23 David Miller <davem@davemloft.net>:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 23 Jan 2012 15:13:19 +0100
>
>> Le lundi 23 janvier 2012 =C3=A0 14:12 +0100, =C5=A0tefan Gula a =C3=A9=
crit :
>>
>>> is there anything else needed from my side to get this code into th=
e
>>> kernel or should I only wait for the maintainers to check it?
>>
>> net-next is/was not yet opened, you shall wait for the good time fra=
me.
>>
>> Dont copy/paste a big message only to add one sentence at its end, i=
ts
>> really a waste of time for many of us.
>
> Also you were told of other ways to achieve the things you want to do=
,
> and I haven't seen any reasonable response that supports still adding
> this new code.
I am sorry about the mistakes I did (still new to kernel submitting
processes). I believe that I also explain to everybody who says
something similar that it is not entirely true and probably never will
be as none of the current SW allows you to create L2 Ethernet
Multipoint VPN solution in such simple way as almost all requires to
run special kind of software in user-space to provide control-plane
for such feature to work. This software must be able to run on various
platforms/architectures which makes it sometimes problematic. My
solution doesn't need this at all and extends the capability of gretap
interfaces in proper manner to be aligned with other forwarding
engines of gretap interfaces. I already have at least one successful
test done in other environment other than my own. So I assume some
people like this approach better than other solutions. For them and
also for myself, I believe it should be added.

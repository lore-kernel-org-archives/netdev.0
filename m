From: David Miller <davem@davemloft.net>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Thu, 26 Jan 2012 13:30:33 -0500 (EST)
Message-ID: <20120126.133033.964571202129052712.davem@davemloft.net>
References: <CAGsizzJnRy74ni-HH=5q1VR4g6sfDPg9SFw4UKgSjJjkSR8OJA@mail.gmail.com>
	<20120125.203746.1977019610549185259.davem@davemloft.net>
	<CAGsizzLYxsc2MGxF7yK_QzS+3bexHa1F_6+NE87u3F18m7=R1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jesse@nicira.com, joseph.glanville@orionvm.com.au,
	eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: steweg@ynet.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGsizzLYxsc2MGxF7yK_QzS+3bexHa1F_6+NE87u3F18m7=R1g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =A6tefan Gula <steweg@ynet.sk>
Date: Thu, 26 Jan 2012 11:57:30 +0100

> 2012/1/26 David Miller <davem@davemloft.net>:
>> From: =A6tefan Gula <steweg@ynet.sk>
>> Date: Wed, 25 Jan 2012 23:57:18 +0100
>>
>>> The performance is one of the most critical thing why I have chosen=
 to
>>> build kernel patch in the first place instead of some user-space ap=
p.
>>> If I used this approach, I would probably end up with patch for
>>> OpenVPN project instead in that time. I am not telling that
>>> openvswitch is not a good place for prototyping, but I believe that
>>> this patch is beyond that border as it successfully run in environm=
ent
>>> with more 98 linux-based APs, used for 4K+ users, with no issue for
>>> more than 2 years. The performance results from Joseph Glanville ev=
en
>>> adds value to it. So I still don't get the point, why my patch and
>>> openvswitch cannot coexists in the kernel together and let user/adm=
in
>>> to choose to correct solution for him/her.
>>
>> You don't even know if openvswitch could provide acceptable levels
>> of performance, because you haven't even tried.
>>
>> I'm not applying your patch.
> Performance of any user-space application is lower than performance o=
f
> something running purely inside the kernel-space only. So still don't
> see any valid reason, why it simply cannot coexists as it doesn't
> breaks any existing functionality at all?

The only userspace component is setting up the rules, the actual
packet processing occurs in the openvswitch kernel code.

Are you really unable to understand this?

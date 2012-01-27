From: Joseph Glanville <joseph.glanville@orionvm.com.au>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Fri, 27 Jan 2012 21:54:12 +1100
Message-ID: <CAOzFzEjqy8G1khxxwKt=hJydz=gUAh8viahA0aVavtyBv7+MXA@mail.gmail.com>
References: <CAGsizzJnRy74ni-HH=5q1VR4g6sfDPg9SFw4UKgSjJjkSR8OJA@mail.gmail.com>
	<20120125.203746.1977019610549185259.davem@davemloft.net>
	<CAGsizzLYxsc2MGxF7yK_QzS+3bexHa1F_6+NE87u3F18m7=R1g@mail.gmail.com>
	<20120126.133033.964571202129052712.davem@davemloft.net>
	<CAOzFzEj-UCXwhw0NA=Y=qExG=RdVJB3RAdqU0HrsMo7V+4eGcQ@mail.gmail.com>
	<1327643984.2919.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, steweg@ynet.sk,
	jesse@nicira.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327643984.2919.6.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

I have been testing on the 3.2.X series of kernels and the 3.0.X and
3.1.X prior to that but most of my results are for 3.2.1.
My test hardware includes pairs of hardware (two or more of each)
based on the following chips.

AMD 6140
Intel X5650
Intel Core i5 2400 (desktop)

I conducted throughput and PPS benchmarks using iperf and pktgen.
All tests were performed over a real IP network (IP over Infiniband)
that can operate at a much greater speed than the software is capable
of forwarding at.
If the list is interested I will re-run and post all of my benchmarks
or atleast send them to you personally.
Unfortunately I didn't store the benchmarks (much to my own stupidty)
and I repurposed the hardware for other things.

Yes I was going to mention this in my last email but deleted it on
lack of relevance at the time.
Under pathological load OVS suffers in benchmarks, continual
establishment of new flows is really not good for it - I haven't
observed this personally though.
It does however worry me that this could be used as a viable DoS.. I
don't really know what could be done to mitigate this however.
That aside it's GRE implementation using loopback (internal)
interfaces performs very well and is like I said onpar with Linux
Bridge + GRE.

Are the any specific things you would like to see?
I'm not a networking guru and would welcome any assistance you could
provide on improving my test methodology.
Someone suggested netperf to me the other day, I intend on running
some benchmarks with it next week.

Joseph.

On 27 January 2012 16:59, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Le vendredi 27 janvier 2012 =E0 09:24 +1100, Joseph Glanville a =E9cr=
it :
>> David is correct, the forwarding speed of Open vSwitch is at parity
>> with the Linux Bridging module and its tunneling speed is actually
>> slightly faster than the in kernel GRE implementation. I have tested
>> this across a variety of configurations.
>
> Thanks for this input ! When was this tested exactly, and do you have
> some "perf tool" reports to provide ?
>
> GRE is lockless since one year or so (modulo how is setup the tunnel =
as
> discovered recently)
>
> Also please note that openvSwitch is said to be fast path only on
> established flows.
>
>
>



--=20
=46ounder | Director | VP Research
Orion Virtualisation Solutions=A0|=A0www.orionvm.com.au=A0| Phone: 1300=
 56
99 52 | Mobile: 0428 754 846

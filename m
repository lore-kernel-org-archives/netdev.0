From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@wide.ad.jp>
Subject: Re: ICMPv6 ratelimiting, which /proc-settings related?
Date: Tue, 16 Jul 2002 16:30:57 +0900 (JST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020716.163057.16459867.yoshfuji@wide.ad.jp>
References: <17380000.1026547066@localhost>
	<20020715.024401.17983126.yoshfuji@wide.ad.jp>
	<14790000.1026803266@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <14790000.1026803266@localhost>
List-Id: netdev.vger.kernel.org

In article <14790000.1026803266@localhost> (at Tue, 16 Jul 2002 09:07:46 +0200), Peter Bieringer <pb@bieringer.de> says:

> > Is introducing /proc/sys/net/ipv6/icmp/all/icmpv6_time reasonable?
> 
> Is HZ completly arch independed? Afair, it was CPU depended (like
> grep HZ include/asm/param.h) shows.

We already have proc_dointvec_jiffies().
We can use it to make that sysctl be arch independent.


> Mho: Better name:
> 
> /proc/sys/net/ipv6/icmp/all/icmpv6_rate
> 
> I would suggest use of unit 1/s and run conversion internally.
> Therfore
> 1 -> 1/s
> 10 -> 10/s
> 100 -> 100/s
> 0.1 -> 1/10s

ah, ipv4 uses /proc/sys/net/ipv4/icmp_*_rate,
icmpv6_rate sounds reasonable.

--yoshfuji

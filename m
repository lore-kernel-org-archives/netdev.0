From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@wide.ad.jp>
Subject: Re: ICMPv6 ratelimiting, which /proc-settings related?
Date: Mon, 15 Jul 2002 02:44:01 +0900 (JST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020715.024401.17983126.yoshfuji@wide.ad.jp>
References: <17380000.1026547066@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <17380000.1026547066@localhost>
List-Id: netdev.vger.kernel.org

In article <17380000.1026547066@localhost> (at Sat, 13 Jul 2002 09:57:46 +0200), Peter Bieringer <pb@bieringer.de> says:

> extending my IPv6-howto with information about the /proc-FS I found
> that there is no setting for ICMPv6 rate limiting.

icmpv6_xrlim_allow() controls rate limiting.

A variable named sysctl_icmpv6_time lives in net/ipv6/icmp.c, but
sysctl does not exist in fact...

Is introducing /proc/sys/net/ipv6/icmp/all/icmpv6_time reasonable?

--yoshfuji

From: Marcin Kaminski <maxiu@man.poznan.pl>
Subject: Re: socket(PF_INET6, SOCK_RAW, IPPROTO_ICMPV6)
Date: Thu, 13 Mar 2003 11:40:55 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.44.0303131135110.20553-100000@rose.man.poznan.pl>
References: <20030313.003341.49620358.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-2
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030313.003341.49620358.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 13 Mar 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> No; recvmsg() and IPV6_PKTINFO socket options is the SIMPLE way for
> obtaining source and destination address.

OK, it works very well, but is there a way which is common to IPv4 and
IPv6 to get ICMP packets?
Obtaining addresses is common to both protocols, but now I get IP header +
ICMP header from IPv4 sockets, and ICMP header from IPv6 sockets, so I
must process them differently (basic ICMP packets have the same structure,
only different values so routines for ICMP could be universal).
You wrote that there is no portable way to obtain IPv6 + ICMPv6, so is
there a way to portable obtain only ICMPv4 (without IPv4 header)?

With regards

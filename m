From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: socket(PF_INET6, SOCK_RAW, IPPROTO_ICMPV6)
Date: Wed, 12 Mar 2003 21:39:03 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030312.213903.04850857.yoshfuji@linux-ipv6.org>
References: <Pine.GSO.4.44.0303121313240.17866-100000@rose.man.poznan.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: maxiu@man.poznan.pl
In-Reply-To: <Pine.GSO.4.44.0303121313240.17866-100000@rose.man.poznan.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.GSO.4.44.0303121313240.17866-100000@rose.man.poznan.pl> (at Wed, 12 Mar 2003 13:17:47 +0100 (CET)), Marcin Kaminski <maxiu@man.poznan.pl> says:

> When I create socket like:
>     interfaceSocket = socket(PF_INET, SOCK_RAW, IPPROTO_ICMP);
> I receive ICMPv4 packets with IP header, but when I use
>     interfaceSocket = socket(PF_INET6, SOCK_RAW, IPPROTO_ICMPV6);
> I receive ICMPv6 packets WITHOUT IPv6 header.

It is because of the specification (RFC2292).


> What should I do in order to get full packet?
> Man pages of raw(7) tell:

There're no portable way to send/receive whole packet including 
IPv6 header (and possible extension header(s)).

> What should I do in order to get full packet?
> Man pages of raw(7) tell:
> 
> For receiving the IP header is always included in the packet.
> 
> But it is not true for IPv6 :(

It is an error of that manpage.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

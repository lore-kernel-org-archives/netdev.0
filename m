From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: IPv6 bugs introduced in 2.4.21
Date: Wed, 18 Jun 2003 22:42:57 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030618.224257.130940019.yoshfuji@linux-ipv6.org>
References: <1055793048.24660.160.camel@slurv.ws.pasop.tomt.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-users@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: andre@skjellin.no
In-Reply-To: <1055793048.24660.160.camel@slurv.ws.pasop.tomt.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <1055793048.24660.160.camel@slurv.ws.pasop.tomt.net> (at 16 Jun 2003 21:50:48 +0200), Andre Tomt <andre@skjellin.no> says:

> I mailed you guys a little while ago on the "unable to use
> SOMENETWORK::0000 as a nexthop gateway" bug in 2.4.21-pre/rc a while
> ago. It is still present in 2.4.21, rendering the "first" /128 of a
> arbitrary prefixlen unusable - :0000. This is especially bad with /127
> tunnels, rendering :0000 and :0001 unusable). But! There is one more
:

This is NOT the bug but by the spec.
prefix:: is an anycast address, not a unicast;
you cannot use it like an unicast address.

Well...

Do you really need to assign global address on the point-to-point device? 
If yes, you should not use /127 prefix; please use /64 instead.

Thank you.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

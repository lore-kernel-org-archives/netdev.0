From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Fri, 11 Jul 2003 00:55:42 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711.005542.04973601.yoshfuji@linux-ipv6.org>
References: <20030710154302.GE1722@zip.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, pekkas@netcore.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: cat@zip.com.au
In-Reply-To: <20030710154302.GE1722@zip.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030710154302.GE1722@zip.com.au> (at Fri, 11 Jul 2003 01:43:03 +1000), CaT <cat@zip.com.au> says:

> With 2.4.21-pre2 I can get a nice tunnel going over my ppp connection
> and as such get ipv6 connectivity. I think went to 2.4.21 and then to
> 2.4.22-pre4 and bringing up the tunnel fails as follows:
:
> ip addr add 3ffe:8001:000c:ffff::37/127 dev sit1
>  ip route add ::/0 via 3ffe:8001:000c:ffff::36 
> RTNETLINK answers: Invalid argument

This is not bug, but rather misconfiguration;
you cannot use prefix::, which is mandatory subnet routers 
anycast address, as unicast address.

Thank you.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

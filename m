From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling broken
Date: Fri, 11 Jul 2003 01:18:58 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711.011858.117900702.yoshfuji@linux-ipv6.org>
References: <20030711.005542.04973601.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0307101906160.18224-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cat@zip.com.au, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0307101906160.18224-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0307101906160.18224-100000@netcore.fi> (at Thu, 10 Jul 2003 19:08:20 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:

> While technically correct, I'm still not sure if this is (pragmatically) 
> the correct approach.  It's OK to set a default route to go to the 
> subnet routers anycast address (so, setting a route to prefix:: should 
> not give you EINVAL).

But, on the other side cannot use prefix::, and
the setting is rather non-sense.

We should educate people not to use /127; use /64 instead.
v6ops? :-)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

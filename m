From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Sysctl for ICMPv6 Rate Limitation
Date: Thu, 24 Oct 2002 14:55:51 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021024.145551.130454003.yoshfuji@linux-ipv6.org>
References: <20021024.135055.10632889.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0210240847280.8872-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: usagi@linux-ipv6.org, pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0210240847280.8872-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0210240847280.8872-100000@netcore.fi> (at Thu, 24 Oct 2002 08:50:25 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:

> > +icmp/*:
> > +ratelimit - INTEGER
> > +	Limit the maximal rates for sending ICMPv6 packets.
> > +	0 to disable any limiting, otherwise the maximal rate in jiffies(1)
> > +	Default: 100
> > +
> 
> Does this rate-limit all ICMPv6 packets or just ICMPv6 error messages (as 
> specified in ICMPv6 specifications).
> 
> If all, I believe the default of rate-limiting everything is unacceptable.

This patch just adds sysctl.  It is my documentation error...
is s/ICMPv6 packets/ICMPv6 error packets/ ok?

(I need to do s/100/HZ/, too; This also lives in ICMP(v4)).

--yoshfuji

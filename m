From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: Sysctl for ICMPv6 Rate Limitation
Date: Thu, 24 Oct 2002 08:50:25 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210240847280.8872-100000@netcore.fi>
References: <20021024.135055.10632889.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>, <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20021024.135055.10632889.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 24 Oct 2002, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> This patch add sysctl for icmp6 rate limit.
> This patch is against 2.4.20-pre11 (see below).

...

> +icmp/*:
> +ratelimit - INTEGER
> +	Limit the maximal rates for sending ICMPv6 packets.
> +	0 to disable any limiting, otherwise the maximal rate in jiffies(1)
> +	Default: 100
> +

Does this rate-limit all ICMPv6 packets or just ICMPv6 error messages (as 
specified in ICMPv6 specifications).

If all, I believe the default of rate-limiting everything is unacceptable.

Note that in the patch does not seem to add the rate-limit sysctl to any 
functions -- was that to happen in some other patch?

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords

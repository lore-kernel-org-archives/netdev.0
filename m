From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: Sysctl for ICMPv6 Rate Limitation
Date: Thu, 24 Oct 2002 08:59:16 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210240858060.8872-100000@netcore.fi>
References: <20021024.145551.130454003.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: usagi@linux-ipv6.org, <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20021024.145551.130454003.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 24 Oct 2002, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> In article <Pine.LNX.4.44.0210240847280.8872-100000@netcore.fi> (at Thu, 24 Oct 2002 08:50:25 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:
> 
> > > +icmp/*:
> > > +ratelimit - INTEGER
> > > +	Limit the maximal rates for sending ICMPv6 packets.
> > > +	0 to disable any limiting, otherwise the maximal rate in jiffies(1)
> > > +	Default: 100
> > > +
> > 
> > Does this rate-limit all ICMPv6 packets or just ICMPv6 error messages (as 
> > specified in ICMPv6 specifications).
> > 
> > If all, I believe the default of rate-limiting everything is unacceptable.
> 
> This patch just adds sysctl.  It is my documentation error...
> is s/ICMPv6 packets/ICMPv6 error packets/ ok?
> 
> (I need to do s/100/HZ/, too; This also lives in ICMP(v4)).

That change fine with me, thanks.

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords

From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH]Add new IPv6 MIBs counters support through netlink
Date: Thu, 27 May 2004 08:58:12 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040527.085812.33823249.yoshfuji@linux-ipv6.org>
References: <20040527.080828.06774575.yoshfuji@linux-ipv6.org>
	<OFA97F4753.DC8C93AD-ON87256EA0.0080DAAB-07256EA0.00814B08@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, mashirle@us.ibm.com, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: xma@us.ibm.com
In-Reply-To: <OFA97F4753.DC8C93AD-ON87256EA0.0080DAAB-07256EA0.00814B08@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OFA97F4753.DC8C93AD-ON87256EA0.0080DAAB-07256EA0.00814B08@us.ibm.com> (at Wed, 26 May 2004 16:32:04 -0700), Shirley Ma <xma@us.ibm.com> says:

> > Without adding support for u64 counter, it does not make sense to add
> > new interface. You can add new counter to the end of the structures.
> 
> It's not good to add new counters to the end of the old structure. The mib 
> 
> number and offset will be wrong.

I don't think so.
But, even if so, we can add only missing stats.

> >This also contains per-interface statistics support.
> (I rember that you said that) we should add idev into an route and avoid
> get/put idev.
> 
> Only a few get/put idev there, not too many. And in some places there are 
> no 
> route, no we can't use idev in route.

okay.

> > I strongly do not want to poeple to change their code twice to support
> draft-ietf-ipv6-rfc2011-update-XX.txt.
> 
> All the counters not just IP will be eventually 64 bits. We can fix it 
> later. And 
> if we implement 64 counters here, there is performance issue on some 
> architectures which don't support atmoic 64 for 32 bit platform.

I strongly do not want to change interface twice to support these new
statistics.

--yoshfuji @ driving traffic jam

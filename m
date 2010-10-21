From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [PATCH 7/9] tproxy: added IPv6 support to the TPROXY target
Date: Thu, 21 Oct 2010 11:33:24 +0200
Message-ID: <1287653604.13326.8.camel@este.odu>
References: <20101020112118.6260.31618.stgit@este.odu>
	 <20101020112118.6260.51773.stgit@este.odu>
	 <alpine.LNX.2.01.1010211042190.22922@obet.zrqbmnf.qr>
	 <1287651014.13326.2.camel@este.odu>
	 <alpine.LNX.2.01.1010211113020.22922@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1010211113020.22922@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, 2010-10-21 at 11:14 +0200, Jan Engelhardt wrote:
> On Thursday 2010-10-21 10:50, KOVACS Krisztian wrote:
> 
> >Hi,
> >
> >On Thu, 2010-10-21 at 10:47 +0200, Jan Engelhardt wrote:
> >> On Wednesday 2010-10-20 13:21, KOVACS Krisztian wrote:
> >> > 
> >> > /* TPROXY target is capable of marking the packet to perform
> >> >  * redirection. We can get rid of that whenever we get support for
> >> >  * mutliple targets in the same rule. */
> >> >-struct xt_tproxy_target_info {
> >> >+struct xt_tproxy_target_info_v0 {
> >> > 	u_int32_t mark_mask;
> >> > 	u_int32_t mark_value;
> >> > 	__be32 laddr;
> >> > 	__be16 lport;
> >> > };
> >> 
> >> You cannot change the struct name either, or it may break userspace
> >> compilations.
> >
> >True, though iptables has its own copy of the header anyway.
> 
> There is - or so I always hear - other userspace programs.
> 
> As for iptables, we only do the copy so that it compiles independent of 
> the kernel version. You have to assume that the headers can be updated 
> at any time.

Sure, I wasn't implying we shouldn't fix this in the patch, I just doubt
there's anything else other than iptables using this and iptables itself
isn't affected.

Anyway, I've fixed it. Thanks, Jan.

--KK



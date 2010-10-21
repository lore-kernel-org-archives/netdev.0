From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 7/9] tproxy: added IPv6 support to the TPROXY target
Date: Thu, 21 Oct 2010 11:14:24 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1010211113020.22922@obet.zrqbmnf.qr>
References: <20101020112118.6260.31618.stgit@este.odu>  <20101020112118.6260.51773.stgit@este.odu>  <alpine.LNX.2.01.1010211042190.22922@obet.zrqbmnf.qr> <1287651014.13326.2.camel@este.odu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:40344 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755496Ab0JUJO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 05:14:26 -0400
In-Reply-To: <1287651014.13326.2.camel@este.odu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 2010-10-21 10:50, KOVACS Krisztian wrote:

>Hi,
>
>On Thu, 2010-10-21 at 10:47 +0200, Jan Engelhardt wrote:
>> On Wednesday 2010-10-20 13:21, KOVACS Krisztian wrote:
>> > 
>> > /* TPROXY target is capable of marking the packet to perform
>> >  * redirection. We can get rid of that whenever we get support for
>> >  * mutliple targets in the same rule. */
>> >-struct xt_tproxy_target_info {
>> >+struct xt_tproxy_target_info_v0 {
>> > 	u_int32_t mark_mask;
>> > 	u_int32_t mark_value;
>> > 	__be32 laddr;
>> > 	__be16 lport;
>> > };
>> 
>> You cannot change the struct name either, or it may break userspace
>> compilations.
>
>True, though iptables has its own copy of the header anyway.

There is - or so I always hear - other userspace programs.

As for iptables, we only do the copy so that it compiles independent of 
the kernel version. You have to assume that the headers can be updated 
at any time.

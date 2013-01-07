From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/3] netpoll: add IPv6 support
Date: Sun, 06 Jan 2013 19:49:17 -0800 (PST)
Message-ID: <20130106.194917.2049529796787288137.davem@davemloft.net>
References: <1357269273-7575-1-git-send-email-amwang@redhat.com>
	<20130103.192041.782458185484678551.davem@davemloft.net>
	<1357527485.20798.4.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37533 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753396Ab3AGDtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2013 22:49:20 -0500
In-Reply-To: <1357527485.20798.4.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon, 07 Jan 2013 10:58:05 +0800

> On Thu, 2013-01-03 at 19:20 -0800, David Miller wrote:
>> From: Cong Wang <amwang@redhat.com>
>> Date: Fri,  4 Jan 2013 11:14:30 +0800
>> 
>> > (Resend with a cover letter)
>> > 
>> > v3: fix CONFIG_IPV6=m case
>> > 
>> > v2: use bool for ipv6 flag
>> >     fix !CONFIG_IPV6 case
>> > 
>> > This patchset implements netpoll over IPv6.
>> 
>> Thanks for submitting this properly.
>> 
>> But disallowing ipv6 netpoll support when IPV6=m is an unacceptable
>> limitation, compiling IPV6 as a module is common and in fact
>> recommended.
>> 
>> We've solved problems like this before, by putting the needed ipv6
>> routines into a seperate library that is built statically into the
>> kernel when necessary.
>> 
>> You should use a similar approach here.
> 
> Hmm, here we need ndisc_parse_options() and udp6_csum_init(). Not sure
> if both can be inlined?

I didn't say "inline", read my email again.

We put such routines into a static library of ipv6 routines
that gets statically built into vmlinux even if ipv6 is
modular.

I'm not explaining this agin.

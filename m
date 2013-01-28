From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Patch net-next] pktgen: use the net namespace of current process instead of init_net
Date: Sun, 27 Jan 2013 19:13:45 -0800
Message-ID: <8738xm0zkm.fsf@xmission.com>
References: <1359340387-18004-1-git-send-email-amwang@redhat.com>
	<87mwvu10rj.fsf@xmission.com> <1359341852.20444.10.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:35136 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752139Ab3A1DN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 22:13:56 -0500
In-Reply-To: <1359341852.20444.10.camel@cr0> (Cong Wang's message of "Mon, 28
	Jan 2013 10:57:32 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> writes:

> On Sun, 2013-01-27 at 18:48 -0800, Eric W. Biederman wrote:
>> Cong Wang <amwang@redhat.com> writes:
>> 
>> > From: Cong Wang <amwang@redhat.com>
>> >
>> > Use the net namespace of the current process loading
>> > pktgen module.
>> 
>> Why not add proper support for multiple network namespaces?
>> 
>> It looks like the proc files could be created in each network namespace
>> and be controlled from there.
>
> Hmm, I didn't think much about this. You are right... we could probably
> make these proc files per-net.

>> Your patch below looks like it could have some unintended effects
>> if pktgen was loaded automatically or compiled into the kernel.
>> 
>
> In this case, 'current' should be the init process whose net namespace
> is init_net, no?

If it is a kernel thread that decided to load the module.  If it
something else who knows.  To my knowledge there are no guarantees
and I'm not particularly interested in having to worry about current
making sense in a module.

Eric

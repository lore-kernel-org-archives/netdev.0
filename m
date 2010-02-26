From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Fri, 26 Feb 2010 16:58:22 -0500
Message-ID: <4B8843FE.4000404@cs.columbia.edu>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>	<4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>	<4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>	<m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi>	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org> <4B883987.6090408@parallels.com>	<m1bpfbwuze.fsf@fess.ebiederm.org> <4B883E6F.1060907@parallels.com> <m13a0nwu6p.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Ben Greear <greearb@candelatech.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brinza.cc.columbia.edu ([128.59.29.8]:57728 "EHLO
	brinza.cc.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966357Ab0BZV6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 16:58:40 -0500
In-Reply-To: <m13a0nwu6p.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Eric W. Biederman wrote:
> Pavel Emelyanov <xemul@parallels.com> writes:
> 
>>>> Yet another set of per-namespace IDs along with CLONE_NEWXXX ones?
>>>> I currently have a way to create all namespaces we have with one
>>>> syscall. Why don't we have an ability to enter them all with one syscall?
>>> The CLONE_NEWXXX series of bits has been an royal pain to work with,
>>> and it appears to be unnecessary complications for no gain.
>> That's the answer for the "Yet another set..." question.
>> How about the "Why don't we have..." one?
> 
> I am not certain which question you are asking:
> 
> Why don't we have an ability to enter all namespaces with one syscall
> invocation?

That's how I understood the question, and I, too, wonder why not ?

By the way, an alternative to using bitmap is to change the prototype
of setns() to accept an array of FD's:

	int setns(int *fds, int nfds);

So the process will atomically enter all the namespaces as specified
by the FDs.

Oren.

> 
> Why don't we have a syscall that allows us to enter every namespace?
> 
> Eric
> 
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 

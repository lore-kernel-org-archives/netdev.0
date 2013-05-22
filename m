From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: linux-next: manual merge of the akpm tree with the net-next tree
Date: Wed, 22 May 2013 09:48:43 +0200
Message-ID: <519C785B.6070104@redhat.com>
References: <20130521130438.1ecdf535ab2461888abbe0c3@linux-foundation.org> <20130522.000748.454683591881350280.davem@davemloft.net> <20130522001458.af0f4ab5.akpm@linux-foundation.org> <20130522.001909.837849096281513655.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, nschichan@freebox.fr
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21922 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755384Ab3EVHs4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 03:48:56 -0400
In-Reply-To: <20130522.001909.837849096281513655.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2013 09:19 AM, David Miller wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Wed, 22 May 2013 00:14:58 -0700
>
>> On Wed, 22 May 2013 00:07:48 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
>>
>>> From: Andrew Morton <akpm@linux-foundation.org>
>>> Date: Tue, 21 May 2013 13:04:38 -0700
>>>
>>>> Nicolas, I think the patches need a re-check so I'll drop the versions
>>>> which I presently have.  Please refresh, retest and resend when
>>>> convenient?  It'll need to be against linux-next, which is where the
>>>> conflicting (vfree/module_free) changes have occurred.
>>>
>>> How about working against net-next and submitting your patches to netdev
>>> just like the rest of the world?
>>
>> Well that's probably practical.  But the patchset is a seccomp
>> enhancement for (at present) ARM.  Not exactly net stuff, or anything
>> which netdev readers are likely to spend a lot of time testing and
>> reviewing.
>
> The seccomp BPF bits we reviewed and were interested in completely, because
> we're going to have to support JIT'ing all of that stuff on every cpu and
> we're interested how it fits into the existing BPF codes and infrastructure.

+1

seccomp is wired with BPF (JITs in arch/*/net/ + net/core/filter.c) and that's
part of networking, so they should go through netdev. This makes it also way
easier for review.

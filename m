From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: vxlan: do not use vxlan_net before checking
 event type
Date: Sat, 18 Jan 2014 20:47:49 +0100
Message-ID: <52DADA65.3030508@redhat.com>
References: <1389959706-30976-1-git-send-email-dborkman@redhat.com> <CAM_iQpV4FGdbHo9UVFhN9yqhZuGEZdrynikvrTZ0YZJTPVCmLg@mail.gmail.com> <52D97746.1040408@redhat.com> <CAM_iQpUoQcHpQJn-nYp9mO+XXMmXSjFxy3ASwchAH-qECoz9OA@mail.gmail.com> <1390065511.31367.535.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_iQpV5NO5YZkQ3dSj_GYhNE2jUdwcYgbX1uNaFua71a266HQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10803 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751347AbaARTr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Jan 2014 14:47:57 -0500
In-Reply-To: <CAM_iQpV5NO5YZkQ3dSj_GYhNE2jUdwcYgbX1uNaFua71a266HQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2014 06:57 PM, Cong Wang wrote:
> On Sat, Jan 18, 2014 at 9:18 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Fri, 2014-01-17 at 19:50 -0800, Cong Wang wrote:
>>> On Fri, Jan 17, 2014 at 10:32 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>>>>
>>>> If you want to do cleanups, whatever, I really don't care.
>>>> You had your chance to complain about that when you reviewed
>>>> the initial version ... it has nothing to do with the fix.
>>>
>>> This is not for stable, as long as it doesn't harm the readability
>>> we are free to do any cleanup's.
>>>
>>> If unsure, check Eric's patch for tunnel dst cache.
>>>
>>> BTW, I am the original author of the patch, you just updated
>>> it *trivially* and set yourself as the author. :) I don't mind, but
>>> remember that this may be not appropriate for others. At
>>> very least I didn't and don't do this myself.
>>
>> Hmm... Daniel mentioned in the changelog you wrote the initial patch,
>> and you are credited as the author of the patch, since he kept your
>> "Signed-off-by: ..." as the first one.
>
> Author == 'From: ...', you knew it, right?
>
> But WITHOUT even asking for my permission. I am sure this is
> not how we usually work. At least, why not ask me before doing
> anything? Why not give me a chance to response?
>
>> Quite frankly, keeping vxlan_handle_lowerdev_unregister() was the right
>> choice.
>>
>> Stop thinking that a function needs to be used more than once to have
>> the right to exist. Splitting code in small parts ease readability and
>> code reuse/refactor, this should be obvious to you.
>
> When did I say because that it is only used once? Please, stop guessing
> my mind.

Cong, I'm really tired of discussing this BS with you, and this is my
last mail on this topic.

You said "There is no need to keep vxlan_handle_lowerdev_unregister(),
it is too short." I, however, think keeping vxlan_handle_lowerdev_unregister()
is the right choice as it makes the code more readable, plus you clearly
agreed with the code earlier as you've given your Reviewed-by tag. You
even got your Fixes tag wrong and I do care that an actual fix for a bug
has a bit more in-depth commit message telling what's going on. I think
the message in the commit is equally important as the code itself, you
should know. Maybe, I was just in the wrong timezone, but while waiting
for a v2 and not having endless discussions about vxlan_handle_lowerdev_unregister(),
I do care that this gets fixed asap! Clearly, it seems it was an honest
mistake to do so.

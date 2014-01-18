From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net: vxlan: do not use vxlan_net before checking
 event type
Date: Sat, 18 Jan 2014 09:57:17 -0800
Message-ID: <CAM_iQpV5NO5YZkQ3dSj_GYhNE2jUdwcYgbX1uNaFua71a266HQ@mail.gmail.com>
References: <1389959706-30976-1-git-send-email-dborkman@redhat.com>
	<CAM_iQpV4FGdbHo9UVFhN9yqhZuGEZdrynikvrTZ0YZJTPVCmLg@mail.gmail.com>
	<52D97746.1040408@redhat.com>
	<CAM_iQpUoQcHpQJn-nYp9mO+XXMmXSjFxy3ASwchAH-qECoz9OA@mail.gmail.com>
	<1390065511.31367.535.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:41597 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbaARR5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 12:57:18 -0500
Received: by mail-oa0-f51.google.com with SMTP id h16so5530145oag.10
        for <netdev@vger.kernel.org>; Sat, 18 Jan 2014 09:57:17 -0800 (PST)
In-Reply-To: <1390065511.31367.535.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 18, 2014 at 9:18 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-01-17 at 19:50 -0800, Cong Wang wrote:
>> On Fri, Jan 17, 2014 at 10:32 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> >
>> >
>> > If you want to do cleanups, whatever, I really don't care.
>> > You had your chance to complain about that when you reviewed
>> > the initial version ... it has nothing to do with the fix.
>>
>> This is not for stable, as long as it doesn't harm the readability
>> we are free to do any cleanup's.
>>
>> If unsure, check Eric's patch for tunnel dst cache.
>>
>> BTW, I am the original author of the patch, you just updated
>> it *trivially* and set yourself as the author. :) I don't mind, but
>> remember that this may be not appropriate for others. At
>> very least I didn't and don't do this myself.
>
>
> Hmm... Daniel mentioned in the changelog you wrote the initial patch,
> and you are credited as the author of the patch, since he kept your
> "Signed-off-by: ..." as the first one.

Author == 'From: ...', you knew it, right?

But WITHOUT even asking for my permission. I am sure this is
not how we usually work. At least, why not ask me before doing
anything? Why not give me a chance to response?

>
> Quite frankly, keeping vxlan_handle_lowerdev_unregister() was the right
> choice.
>
> Stop thinking that a function needs to be used more than once to have
> the right to exist. Splitting code in small parts ease readability and
> code reuse/refactor, this should be obvious to you.
>

When did I say because that it is only used once? Please, stop guessing
my mind.

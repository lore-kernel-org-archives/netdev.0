From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH net] rtnetlink: fix userspace API breakage for iproute2 < v3.9.0
Date: Thu, 12 Jun 2014 10:44:49 -0700
Message-ID: <CA+55aFxQMw0s1N2SspU-DWbZ-h4mho4dVFrX5qm=ZHKrsUGbmw@mail.gmail.com>
References: <1401279319-29088-1-git-send-email-mschmidt@redhat.com>
	<20140530.174248.715408523447246496.davem@davemloft.net>
	<538DBDB3.7030505@redhat.com>
	<5399B575.7070604@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	michael.riesch@omicron.at
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f176.google.com ([209.85.128.176]:54952 "EHLO
	mail-ve0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852AbaFLRou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 13:44:50 -0400
Received: by mail-ve0-f176.google.com with SMTP id db12so2159668veb.7
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 10:44:49 -0700 (PDT)
In-Reply-To: <5399B575.7070604@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, I have to agree with Michal. If the user-space tool did what it
had to do for old kernels, then new kernels should support the old
semantics.

You can't call it a "bug" - user space does what it does and it was
tested and worked.

And sure, it might have been a bug/misfeature of the old kernel, but
we have to live with what we have done, not blame others. Once user
space starts depending on our bugs, it's *our* problem.

Saying "fix your sh*t" is wrong, when we caused it to begin with.

            Linus

On Thu, Jun 12, 2014 at 7:13 AM, Michal Schmidt <mschmidt@redhat.com> wrote:
> On 06/03/2014 02:21 PM, Michal Schmidt wrote:
>> On 05/31/2014 02:42 AM, David Miller wrote:
>>>
>>> The userspace tool should be fixed on the system, rather than having the
>>> kernel cater to a user tool bug.
>>>
>>> I'm not applying this, sorry.
>>
>> the old version of the userspace tool did what it had to do in order to
>> work with a contemporary kernel. You can call that a bug, but the fact
>> is that it used to work that way.
>>
>> I do not see a difference between "catering to a user tool bug" and
>> "not breaking applications, whether we like them or not" (paraphrasing
>> Linus's message on this very mailing list just 10 days ago).
>
> Dave,
> I am sorry for harping on this, but could you please either reconsider
> the NAK, or explain what considerations are more important than
> userspace compatibility in this case?
>
>> I could understand your objection if my proposed patch could break
>> something else, but you are not saying that, are you?
>
> Michal
>

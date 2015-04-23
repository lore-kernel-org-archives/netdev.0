From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC 2/3] tc: deprecate TC_ACT_QUEUED
Date: Wed, 22 Apr 2015 19:46:35 -0700
Message-ID: <55385D0B.5030103@plumgrid.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>	<1429644476-8914-3-git-send-email-ast@plumgrid.com>	<CAHA+R7MYcKTHmZWtHm9V5_DjdB0zTBhayhsftcqkDFMwCno7dg@mail.gmail.com>	<55381F14.4070708@plumgrid.com> <CAHA+R7Mz0LSZ-S=k7rvUuhXm+GT9w2ve6Ug+YPJ4vqnsrLnfpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:33489 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932076AbbDWCqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 22:46:37 -0400
Received: by pdbnk13 with SMTP id nk13so5561602pdb.0
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 19:46:37 -0700 (PDT)
In-Reply-To: <CAHA+R7Mz0LSZ-S=k7rvUuhXm+GT9w2ve6Ug+YPJ4vqnsrLnfpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/22/15 4:39 PM, Cong Wang wrote:
> On Wed, Apr 22, 2015 at 3:22 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> On 4/21/15 10:02 PM, Cong Wang wrote:
>>>
>>> On Tue, Apr 21, 2015 at 12:27 PM, Alexei Starovoitov <ast@plumgrid.com>
>>> wrote:
>>>>
>>>> TC_ACT_QUEUED was always an alias of TC_ACT_STOLEN.
>>>> Get rid of redundant checks in all qdiscs.
>>>> Instead do it once.
>>>
>>>
>>> The current code can be easily extended, while your code not.
>>> I don't see the need of this change.
>>
>>
>> well, iproute2 doesn't use TC_ACT_QUEUED action at all and
>> TC_ACT_STOLEN is used by mirred. All in-tree qdiscs alias them.
>> If you're saying that some future actions together with
>> some future qdiscs may take advantage of that, then why they didn't
>> use it over the last 10 years?
>> Having both that do the same thing is only confusing.
>> I think having one value to indicate 'stolen' condition makes TC
>> code easier to understand.
>
> Then remove it, I am all for this. ;)

TC_ACT_QUEUED cannot be removed.
Only deprecated with backwards compatibility the way this patch did it.
That should have been obvious.

The other two threads degenerated into non-technical comments.

Anyway, this set was RFC to answer my main question whether I should
continue with tc cleanup or stop right here. I got my answer.

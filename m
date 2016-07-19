From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net_sched: Introduce skbmod action
Date: Tue, 19 Jul 2016 06:28:11 -0400
Message-ID: <578E00BB.1050806@mojatatu.com>
References: <1468744884-8246-1-git-send-email-jhs@emojatatu.com>
 <20160718041933.GB36253@ast-mbp.thefacebook.com>
 <578C7C5C.2070804@mojatatu.com> <578CA4EB.7060703@iogearbox.net>
 <20160718100717.GB30532@pox.localdomain> <578CAEB8.9070805@mojatatu.com>
 <CAM_iQpWo4YyVjoHdDdKLCXu_XO7=H8-2yet3qq6g3BUPtUbW4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:35051 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbcGSK2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 06:28:15 -0400
Received: by mail-lf0-f65.google.com with SMTP id l89so880282lfi.2
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 03:28:14 -0700 (PDT)
In-Reply-To: <CAM_iQpWo4YyVjoHdDdKLCXu_XO7=H8-2yet3qq6g3BUPtUbW4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-18 01:38 PM, Cong Wang wrote:
> On Mon, Jul 18, 2016 at 3:26 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 16-07-18 06:07 AM, Thomas Graf wrote:
>>
>>>
>>> Right. I was at the same point as Jamal and it is nasty to try and
>>> reverse engineer the dumps without any further hints. I assume that's
>>> what he is referring to with difficulties.
>>>
>>
>> That +: if you get me a field which says "dstmac" i dont have to go
>> and start aggregating 32bit chunks to create a 48bit MAC (or worse
>> look at the offset and figure where they come from).
>>
>
> Been there, done that. I debugged u32 filter dumps too, I understand
> your concern.
>
> But this still looks like solvable to me, although it is definitely not easy,
> probably even harder than the parsing logic. I will try to write some
> code for iproute2 to see how far I can go.
>

I am sure that will be useful for someone - just not me.

> Adding a new type of action/filter in kernel just for convenience seems
> overkill. At very least I think we should just extend the existing ones,
> for example, allowing pedit to accept and dump DST_MAC etc. Does this
> sound good to you?
>

Not for me Cong - but i have no doubt it would improve pedit's
usability. Besides that is fixing one app (tc).
What i am trying to do is a common use case. It is an
optimization that has become necessary; your effort could be parallel
to this. Look at how much time we are spending arm chair lawyering this;
please go ahead and do that with iproute2 and let this patch go in. Like
I said this comes from deployment experience and need.

cheers,
jamal

From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH net-next 1/1] Introduce skbmod action
Date: Sun, 17 Jul 2016 09:32:09 -0700
Message-ID: <CAM_iQpV45uJw-dZs6rpyD8qdE1uoZGwPDWzbZ+3CbkNQE1VOLQ@mail.gmail.com>
References: <1468239164-17898-1-git-send-email-jhs@emojatatu.com>
 <CAM_iQpWNxZjWM-f_siOuXf+w_mgxKay9S8kAmUTD+8YLXp2S+g@mail.gmail.com> <578A4498.9030307@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34616 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbcGQQc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2016 12:32:29 -0400
Received: by mail-it0-f67.google.com with SMTP id u186so4517604ita.1
        for <netdev@vger.kernel.org>; Sun, 17 Jul 2016 09:32:29 -0700 (PDT)
In-Reply-To: <578A4498.9030307@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 16, 2016 at 7:28 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-07-12 01:10 PM, Cong Wang wrote:
>>
>> On Mon, Jul 11, 2016 at 5:12 AM, Jamal Hadi Salim <jhs@mojatatu.com>
>> wrote:
>>>
>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>>
>>> This action is intended to be an upgrade from a usability perspective
>>> from pedit. Compare this:
>>>
>>
>> Definitely agree we need a more user-friendly interface.
>>
>>>
>>> pedit is a good starting point - but once you start going to a large
>>> number of policies then from a programmability, ops and usability point
>>> of view you need something with more succint params.
>>>
>>
>> But it is still unclear why we can't just build something on top of
>> pedit? Since pedit accepts keys like u32, user-space is free to
>> introduce any wrapper on top of it.
>>
>
>
> That hasnt served us well so far for reasons i described earlier
> especially in the dump case.
> It hasnt served u32 as a classifier well either (yes, those dump
> wrappers exist on the tc user code); i am almost willing to bet
> you didnt even know such a feature existed ;->

But this still sounds like it is solvable, just not yet solved, right?
And we don't have to change kernel space unless we can't
fix user-space.

From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH net-next 1/1] Introduce skbmod action
Date: Sat, 16 Jul 2016 10:28:40 -0400
Message-ID: <578A4498.9030307@mojatatu.com>
References: <1468239164-17898-1-git-send-email-jhs@emojatatu.com>
 <CAM_iQpWNxZjWM-f_siOuXf+w_mgxKay9S8kAmUTD+8YLXp2S+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	nikolay@cumulusnetworks.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:35275 "EHLO
	mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbcGPOhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 10:37:20 -0400
Received: by mail-qt0-f181.google.com with SMTP id j35so73111451qtj.2
        for <netdev@vger.kernel.org>; Sat, 16 Jul 2016 07:37:20 -0700 (PDT)
In-Reply-To: <CAM_iQpWNxZjWM-f_siOuXf+w_mgxKay9S8kAmUTD+8YLXp2S+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-12 01:10 PM, Cong Wang wrote:
> On Mon, Jul 11, 2016 at 5:12 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> This action is intended to be an upgrade from a usability perspective
>> from pedit. Compare this:
>>
>
> Definitely agree we need a more user-friendly interface.
>
>>
>> pedit is a good starting point - but once you start going to a large
>> number of policies then from a programmability, ops and usability point
>> of view you need something with more succint params.
>>
>
> But it is still unclear why we can't just build something on top of
> pedit? Since pedit accepts keys like u32, user-space is free to
> introduce any wrapper on top of it.
>


That hasnt served us well so far for reasons i described earlier
especially in the dump case.
It hasnt served u32 as a classifier well either (yes, those dump
wrappers exist on the tc user code); i am almost willing to bet
you didnt even know such a feature existed ;->

> It should not be a problem for libnl3 to build anything on top too.

And I dont use libnl3 either.
Again, as i stated earlier: pedit is a good first starting point.
At some point usability gets in the way and this is a natural next step.

I am going to work on the patch and will add src mac and ethertype for
completion.

cheers,
jamal

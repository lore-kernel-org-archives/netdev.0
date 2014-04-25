From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] sched, cls: check if we could overwrite actions when
 changing a filter
Date: Fri, 25 Apr 2014 13:41:17 -0700
Message-ID: <CAM_iQpV9g3PR0zPsM_4yHDrGKb+BAFk8=_SO8-x+R_gT9WzwUA@mail.gmail.com>
References: <1397605563-29756-1-git-send-email-xiyou.wangcong@gmail.com>
	<534E77D0.8000307@mojatatu.com>
	<CAM_iQpXRVZ8_keaL-8OkmRVguA29bnTPS2ZHZ0j2SSeB6A=1jQ@mail.gmail.com>
	<534FBFF0.3020606@mojatatu.com>
	<CAM_iQpVqQbXcm0gGxe_JMURPtGYH+iOi8UGgvis5je6g9zbiKQ@mail.gmail.com>
	<53513619.5060202@mojatatu.com>
	<CAM_iQpX13QBbGnsKfD1oL6t331-=wRWFU_0ktdtgngpfE1Z6nA@mail.gmail.com>
	<535259C3.10404@mojatatu.com>
	<CAM_iQpVM-djLiz9Z9Bhz9zac88m8b6t1S-SRUkRxYhOaW_xJvQ@mail.gmail.com>
	<5357A453.6030901@mojatatu.com>
	<CAM_iQpXkihRZN8Uf=KtaFexF1JP66Fztr+q3_tT4sMgOLMxGGQ@mail.gmail.com>
	<535A83CA.4030201@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:39756 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754823AbaDYUlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 16:41:17 -0400
Received: by mail-oa0-f53.google.com with SMTP id j17so4675410oag.26
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2014 13:41:17 -0700 (PDT)
In-Reply-To: <535A83CA.4030201@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 25, 2014 at 8:48 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 04/24/14 17:12, Cong Wang wrote:
>>
>> On Wed, Apr 23, 2014 at 4:30 AM, Jamal Hadi Salim <jhs@mojatatu.com>
>> wrote:
>>>
>>>
>>> I dont see what you are seeing. However, some quick tests will prove it.
>>> Example go from 1->3 actions and backwards 3->1 actions.
>>> I.e create a policy with (handwave) 3 actions and replace it with
>>> another that has only one action. Do this while you are sending a
>>> ping exercising this policy.
>>> I can see how yours with 1->0 and 0->1 will work.
>>
>>
>> See below (with this patch applied):
>>
>
> Ok, thanks Cong. Since you are using this in your system already,
> I am assuming it is tested with running traffic at the same time.

Yes I did.

>
> Please resubmit the patch with my signed off as well..
>

OK, and will rebase it on net-next since it is not an urgent issue.

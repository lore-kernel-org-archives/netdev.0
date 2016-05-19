From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next RFC 1/1] net sched actions: introduce timestamp for
 first time used
Date: Thu, 19 May 2016 09:38:46 -0700
Message-ID: <CAM_iQpW7LQ40XX5G+creyHjQbgdRcKCCJ1f5CbWHjdJdxJPPRA@mail.gmail.com>
References: <1463528337-4986-1-git-send-email-jhs@emojatatu.com>
 <CAM_iQpWXgncANS5MrBzrZiEVSbGzNptrAjisg_K2NTA-PsAMKg@mail.gmail.com>
 <573DA960.8070102@mojatatu.com> <573DAE70.4000504@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Felix Fietkau <nbd@nbd.name>, baronchon@n7mm.org,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:34125 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754980AbcESQjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 12:39:08 -0400
Received: by mail-yw0-f177.google.com with SMTP id j74so83797175ywg.1
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 09:39:07 -0700 (PDT)
In-Reply-To: <573DAE70.4000504@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2016 at 5:15 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-05-19 07:54 AM, Jamal Hadi Salim wrote:
>>
>> On 16-05-18 01:17 PM, Cong Wang wrote:
>
>
>>> I think it is the time to add a wrapper for these tm.XX =
>>> jiffies_to_clock_t(XXX).
>>>
>>
>> Agreed. Will send a patch.
>> Actually I will resend the firstuse as well without RFC tag
>> and the wrapper one as separate patch.
>>
>
> Something like attached - compiles but untested.
> I will test later and do formal submission.

Looks good.

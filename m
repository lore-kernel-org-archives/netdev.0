From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next RFC 1/1] net sched actions: introduce timestamp for
 first time used
Date: Thu, 19 May 2016 07:54:08 -0400
Message-ID: <573DA960.8070102@mojatatu.com>
References: <1463528337-4986-1-git-send-email-jhs@emojatatu.com>
 <CAM_iQpWXgncANS5MrBzrZiEVSbGzNptrAjisg_K2NTA-PsAMKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>, nbd@nbd.name,
	baronchon@n7mm.org, Alexander Duyck <alexander.duyck@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:35711 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754581AbcESLyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 07:54:24 -0400
Received: by mail-ig0-f195.google.com with SMTP id jn6so7219769igb.2
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 04:54:24 -0700 (PDT)
In-Reply-To: <CAM_iQpWXgncANS5MrBzrZiEVSbGzNptrAjisg_K2NTA-PsAMKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-18 01:17 PM, Cong Wang wrote:
> On Tue, May 17, 2016 at 4:38 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
>> index 014f9a6..f581e01 100644
>> --- a/net/sched/act_bpf.c
>> +++ b/net/sched/act_bpf.c
>> @@ -156,6 +156,7 @@ static int tcf_bpf_dump(struct sk_buff *skb, struct tc_action *act,
>>
>>          tm.install = jiffies_to_clock_t(jiffies - prog->tcf_tm.install);
>>          tm.lastuse = jiffies_to_clock_t(jiffies - prog->tcf_tm.lastuse);
>> +       tm.firstuse = jiffies_to_clock_t(jiffies - prog->tcf_tm.firstuse);
>>          tm.expires = jiffies_to_clock_t(prog->tcf_tm.expires);
>
>
> I think it is the time to add a wrapper for these tm.XX =
> jiffies_to_clock_t(XXX).
>

Agreed. Will send a patch.
Actually I will resend the firstuse as well without RFC tag
and the wrapper one as separate patch.

cheers,
jamal

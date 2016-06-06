From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 3/3] net sched actions: aggregate dumping of
 actions timeinfo
Date: Mon, 6 Jun 2016 06:34:44 -0400
Message-ID: <575551C4.4000704@mojatatu.com>
References: <1465136801-19644-1-git-send-email-jhs@emojatatu.com>
 <1465136801-19644-4-git-send-email-jhs@emojatatu.com>
 <CAM_iQpWdfP91GUkhJW70ii15uwr1vEPEpF2b8hkfSPA02NVreg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33664 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbcFFKer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 06:34:47 -0400
Received: by mail-it0-f66.google.com with SMTP id u203so5539507itc.0
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 03:34:46 -0700 (PDT)
In-Reply-To: <CAM_iQpWdfP91GUkhJW70ii15uwr1vEPEpF2b8hkfSPA02NVreg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-06 01:39 AM, Cong Wang wrote:
> On Sun, Jun 5, 2016 at 7:26 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> diff --git a/include/net/act_api.h b/include/net/act_api.h
>> index 8389c00..5453f52 100644
>> --- a/include/net/act_api.h
>> +++ b/include/net/act_api.h
>> @@ -80,6 +80,14 @@ static inline void tcf_lastuse_update(struct tcf_t *tm)
>>                  tm->firstuse = now;
>>   }
>>
>> +static inline void tcf_tm_dump(struct tcf_t *dtm, struct tcf_t *stm)
>
> Nit: const struct tcf_t *stm. ;)
>

Ok, here comes a patch ;->

cheers,
jamal

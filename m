From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 6/6] net sched: ife action fix late binding
Date: Mon, 9 May 2016 07:54:15 -0400
Message-ID: <57307A67.3020909@mojatatu.com>
References: <1462728392-28489-1-git-send-email-jhs@emojatatu.com>
 <1462728392-28489-7-git-send-email-jhs@emojatatu.com>
 <CAM_iQpXfA47LoK-zNBk6QyucA4ogagTiWSbnd0x2CQs-28rw+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35381 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048AbcEILyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 07:54:23 -0400
Received: by mail-ig0-f171.google.com with SMTP id bi2so101682625igb.0
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 04:54:22 -0700 (PDT)
In-Reply-To: <CAM_iQpXfA47LoK-zNBk6QyucA4ogagTiWSbnd0x2CQs-28rw+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-08 11:32 PM, Cong Wang wrote:
> On Sun, May 8, 2016 at 10:26 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> @@ -689,7 +695,7 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
>>          /*
>>             OUTERHDR:TOTMETALEN:{TLVHDR:Metadatum:TLVHDR..}:ORIGDATA
>>             where ORIGDATA = original ethernet header ...
>> -        */
>> +       */
>
> Irrelevant to the bug fix.
>

Same as other response. Dont think it is worth sending a patch just to
indent.

cheers,
jamal

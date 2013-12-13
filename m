From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v2 2/6] net_sched: act: use standard struct list_head
Date: Fri, 13 Dec 2013 10:46:28 -0800
Message-ID: <CAM_iQpVL-dwiwTdVbvM3FPZfaJhSN_pRuB0-nm7sxrFtrSH-2A@mail.gmail.com>
References: <1386910604-1870-1-git-send-email-xiyou.wangcong@gmail.com>
	<1386910604-1870-3-git-send-email-xiyou.wangcong@gmail.com>
	<CABa6K_H_f_9sS4pH2gE2YD_KUHOVMGRwpy1x8Q-i3mFDEmQXjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:34062 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753202Ab3LMSq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 13:46:29 -0500
Received: by mail-oa0-f44.google.com with SMTP id m1so2477026oag.17
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 10:46:28 -0800 (PST)
In-Reply-To: <CABa6K_H_f_9sS4pH2gE2YD_KUHOVMGRwpy1x8Q-i3mFDEmQXjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 12, 2013 at 10:32 PM, Changli Gao <xiaosuo@gmail.com> wrote:
> On Fri, Dec 13, 2013 at 12:56 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>
>> @@ -85,12 +86,18 @@ static inline int
>>  tcf_exts_is_predicative(struct tcf_exts *exts)
>>  {
>>  #ifdef CONFIG_NET_CLS_ACT
>> -       return !!exts->action;
>> +       return list_empty(&exts->head);
>>  #else
>>         return 0;
>>  #endif
>>  }
>>
>
> You missed a "!".
>


Fixed.

Thanks.

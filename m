From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 5/6] net sched: skbedit action fix late
 binding
Date: Mon, 9 May 2016 07:53:43 -0400
Message-ID: <57307A47.9090307@mojatatu.com>
References: <1462728392-28489-1-git-send-email-jhs@emojatatu.com>
 <1462728392-28489-6-git-send-email-jhs@emojatatu.com>
 <CAM_iQpXTTJjs0HBvRDzVY4eHVrGenq2bzkwCQo92vwWV0e9LUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36358 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbcEILxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 07:53:46 -0400
Received: by mail-ig0-f180.google.com with SMTP id u10so101621528igr.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 04:53:46 -0700 (PDT)
In-Reply-To: <CAM_iQpXTTJjs0HBvRDzVY4eHVrGenq2bzkwCQo92vwWV0e9LUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-08 11:28 PM, Cong Wang wrote:

>> +       /* if action exists and this is a late filter bind, no need
>> +        * to continue processing
>> +       */
>
> This comment looks useless, at least for me, because the code
> is already clear.
>

I will get rid of it. Note: I added it to one patch only incase
the feature of late binding was foreign to some people.

>
>> +       if (aexists && bind)
>> +                       return 0;
>
>
> One extra tab?
>

thanks for catching it.

cheers,
jamal

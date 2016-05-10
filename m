From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 1/6] net sched: vlan action fix late binding
Date: Tue, 10 May 2016 16:52:06 -0400
Message-ID: <573249F6.7030105@mojatatu.com>
References: <1462728392-28489-1-git-send-email-jhs@emojatatu.com>
 <1462728392-28489-2-git-send-email-jhs@emojatatu.com>
 <CAM_iQpVtk1AowsH_jDz24yNqAZTCOPtMk=KM0dhFtYUJLfOk4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:36718 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbcEJUwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 16:52:16 -0400
Received: by mail-ig0-f179.google.com with SMTP id lr7so20302170igb.1
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 13:52:16 -0700 (PDT)
In-Reply-To: <CAM_iQpVtk1AowsH_jDz24yNqAZTCOPtMk=KM0dhFtYUJLfOk4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-08 11:08 PM, Cong Wang wrote:

>> +               if (aexists)
>> +                       tcf_hash_release(a, bind);
>
>
> Introduce a goto to reduce duplicated cleanup code?
>

I addressed all your comments except for above goto. There are different
return codes for all failures - and the cleverness of a goto seems
unecessary.

cheers,
jamal

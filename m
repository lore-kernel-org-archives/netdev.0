From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 2/2] net_sched: use void pointer for filter
 handle
Date: Sun, 6 Aug 2017 07:46:06 -0400
Message-ID: <e03eb2b1-df7c-ca61-1950-ed7c129f0235@mojatatu.com>
References: <20170805043143.13680-1-xiyou.wangcong@gmail.com>
 <20170805043143.13680-3-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36972 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbdHFLqI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 07:46:08 -0400
Received: by mail-io0-f194.google.com with SMTP id c74so3746131iod.4
        for <netdev@vger.kernel.org>; Sun, 06 Aug 2017 04:46:08 -0700 (PDT)
In-Reply-To: <20170805043143.13680-3-xiyou.wangcong@gmail.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-08-05 12:31 AM, Cong Wang wrote:
> Now we use 'unsigned long fh' as a pointer in every place,
> it is safe to convert it to a void pointer now. This gets
> rid of many casts to pointer.
> 

I dont recall why unsigned long was used back then (by Alexey)
given C has always allowed void * assigned to other types
(and such a pattern is widely used in the kernel)

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal

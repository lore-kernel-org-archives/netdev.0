From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Tue, 18 Apr 2017 21:12:39 -0400
Message-ID: <fef13302-dee8-b063-07e3-3aad4a873fbf@mojatatu.com>
References: <1492564082-28685-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jiri@resnulli.us,
        xiyou.wangcong@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:36268 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757863AbdDSBMl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 21:12:41 -0400
Received: by mail-it0-f45.google.com with SMTP id b15so20649093iti.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 18:12:41 -0700 (PDT)
In-Reply-To: <1492564082-28685-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please ignore - I will resend. This is corrupt.
Sorry - I will label the next one as v2 even though it is v3.

cheers,
jamal

On 17-04-18 09:08 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> When you dump hundreds of thousands of actions, getting only 32 per
> dump batch even when the socket buffer and memory allocations allow
> is inefficient.
>
> With this change, the user will get as many as possibly fitting

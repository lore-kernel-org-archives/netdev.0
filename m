From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net 1/2] act_ife: only acquire tcf_lock for existing
 actions
Date: Thu, 23 Jun 2016 07:10:29 -0400
Message-ID: <576BC3A5.3070509@mojatatu.com>
References: <1466455039-23268-1-git-send-email-xiyou.wangcong@gmail.com>
 <1466455039-23268-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: khoroshilov@ispras.ru
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36833 "EHLO
	mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbcFWLKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 07:10:31 -0400
Received: by mail-qk0-f194.google.com with SMTP id l81so15289983qke.3
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 04:10:30 -0700 (PDT)
In-Reply-To: <1466455039-23268-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-20 04:37 PM, Cong Wang wrote:
> Alexey reported that we have GFP_KERNEL allocation when
> holding the spinlock tcf_lock. Actually we don't have
> to take that spinlock for all the cases, especially
> for the new one we just create. To modify the existing
> actions, we still need this spinlock to make sure
> the whole update is atomic.
>
> For net-next, we can get rid of this spinlock because
> we already hold the RTNL lock on slow path, and on fast
> path we can use RCU to protect the metalist.
>
> Joint work with Jamal.
>
> Reported-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal

From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 2/3] sched: act: ife: migrate to use per-cpu
 counters
Date: Thu, 12 Oct 2017 21:39:12 -0400
Message-ID: <d95f26da-1613-1a13-d806-6c418dbd6a4a@mojatatu.com>
References: <20171011211608.22692-1-aring@mojatatu.com>
 <20171011211608.22692-3-aring@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, bjb@mojatatu.com,
        Yotam Gigi <yotamg@mellanox.com>
To: Alexander Aring <aring@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:48802 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753327AbdJMBjO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 21:39:14 -0400
Received: by mail-io0-f196.google.com with SMTP id j17so7436267iod.5
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 18:39:14 -0700 (PDT)
In-Reply-To: <20171011211608.22692-3-aring@mojatatu.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-10-11 05:16 PM, Alexander Aring wrote:
> This patch migrates the current counter handling which is protected by a
> spinlock to a per-cpu counter handling. This reduce the time where the
> spinlock is being held.
> 
> Signed-off-by: Alexander Aring <aring@mojatatu.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal

From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC Patch net-next 1/6] net_sched: use RCU for action hash table
Date: Tue, 6 Sep 2016 08:47:54 -0400
Message-ID: <1e33ca48-5c03-232b-9700-56a0510700b8@mojatatu.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472795840-31901-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36453 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932406AbcIFMr4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 08:47:56 -0400
Received: by mail-oi0-f68.google.com with SMTP id u131so5325407oif.3
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 05:47:56 -0700 (PDT)
In-Reply-To: <1472795840-31901-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-02 01:57 AM, Cong Wang wrote:
> We already free tc actions in a RCU callback, so here
> we just need to convert the hash table operations to
> RCU API's.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

This one stands on its own merit, no?
So:
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal

From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v3 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 29 Aug 2016 07:40:20 -0400
Message-ID: <ffd6e8ca-118b-9cea-9c58-fb1820f9e735@mojatatu.com>
References: <1472386756-23085-1-git-send-email-jhs@emojatatu.com>
 <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com>
 <b075631d-92cc-d016-3786-aaacb3d5c13a@mojatatu.com>
 <57C415EB.80806@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:37530 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756705AbcH2LkY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 07:40:24 -0400
Received: by mail-it0-f51.google.com with SMTP id d65so91608844ith.0
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 04:40:23 -0700 (PDT)
In-Reply-To: <57C415EB.80806@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-29 07:00 AM, Daniel Borkmann wrote:

> You could probably just keep these meta data in a separate struct
> managed by RCU that tcf_skbmod points to.
>

Which seem like could be made generic for all actions. Maybe thats
what Cong is thinking.

> One more thing I commented on your last patch already is that you
> would also need f.e. skb_ensure_writable() before mangling.


Sorry missed that. Let me give it an attempt. I think challenge is
going to be what length to use. For now it is ethernet; but i had
a change which swapped VLANs that i took out.

cheers,
jamal

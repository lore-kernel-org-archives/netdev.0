From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net/sched: fix pointer check in gen_handle
Date: Mon, 11 Sep 2017 11:05:55 -0700
Message-ID: <CAM_iQpW9z8A+zSSfTv7M2_ifk15ePLAc4z4CWzTAj3bNOaU9eQ@mail.gmail.com>
References: <1505072930-13049-1-git-send-email-johunt@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Josh Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36277 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750927AbdIKSGQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 14:06:16 -0400
Received: by mail-pf0-f172.google.com with SMTP id e199so15039045pfh.3
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 11:06:16 -0700 (PDT)
In-Reply-To: <1505072930-13049-1-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 10, 2017 at 12:48 PM, Josh Hunt <johunt@akamai.com> wrote:
> Fixes sparse warning about pointer in gen_handle:
> net/sched/cls_rsvp.h:392:40: warning: Using plain integer as NULL pointer
>
> Fixes: 8113c095672f6 ("net_sched: use void pointer for filter handle")
> Signed-off-by: Josh Hunt <johunt@akamai.com>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

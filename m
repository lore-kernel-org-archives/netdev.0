From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: properly handle failure case of tcf_exts_init()
Date: Mon, 22 Aug 2016 10:40:50 -0700
Message-ID: <CAM_iQpVJt9fE_anNXq=Jvi_Ka=BtN-_H365+oEBpFrxJv6dU3A@mail.gmail.com>
References: <1471635414-32433-1-git-send-email-xiyou.wangcong@gmail.com> <09b957e2-5a37-643d-9cc1-2bbddc4ad8b4@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:37829 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754748AbcHVRlL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 13:41:11 -0400
Received: by mail-it0-f46.google.com with SMTP id f6so91654115ith.0
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 10:41:11 -0700 (PDT)
In-Reply-To: <09b957e2-5a37-643d-9cc1-2bbddc4ad8b4@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 5:11 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>
>
> Answered my own question by looking at implementation of kfree();
> ignores NULL (unlike free())

Seriously?

Here is what C standard says about free():

The free function causes the space pointed to by ptr to be
deallocated, that is, made available for further allocation. If ptr is
a null pointer, no action occurs.

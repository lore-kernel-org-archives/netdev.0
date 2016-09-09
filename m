From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch net-next 0/6] net_sched: really switch to RCU for tc actions
Date: Thu, 8 Sep 2016 22:22:17 -0700
Message-ID: <CAM_iQpUFVc4cpjENXyE60ghStQiuHH7byYhwr9RD+8T_CMTjmQ@mail.gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com> <57D03EF5.90602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34087 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbcIIFWi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 01:22:38 -0400
Received: by mail-oi0-f66.google.com with SMTP id a144so151424oii.1
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 22:22:37 -0700 (PDT)
In-Reply-To: <57D03EF5.90602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 7, 2016 at 9:23 AM, John Fastabend <john.fastabend@gmail.com> wrote:
>
> hmm I'm trying to see where the questionable part is in the current
> code? What is it exactly.

All you need is a google search in netdev:

https://www.mail-archive.com/netdev@vger.kernel.org/msg115480.html

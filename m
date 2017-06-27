From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net PATCH] net: sched: Fix one possible panic when no destroy callback
Date: Tue, 27 Jun 2017 09:30:34 -0700
Message-ID: <CAM_iQpXRy=cC2vuhju2Jf9=sJ+Yc6DvkzvFEU_DrRonyhW+E9w@mail.gmail.com>
References: <1498527333-86838-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35084 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751513AbdF0Qaz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 12:30:55 -0400
Received: by mail-wm0-f41.google.com with SMTP id w126so29691797wme.0
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 09:30:55 -0700 (PDT)
In-Reply-To: <1498527333-86838-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 26, 2017 at 6:35 PM,  <gfree.wind@vip.163.com> wrote:
> From: Gao Feng <gfree.wind@vip.163.com>
>
> When qdisc fail to init, qdisc_create would invoke the destroy callback
> to cleanup. But there is no check if the callback exists really. So it
> would cause the panic if there is no real destroy callback like these
> qdisc codel, pfifo, pfifo_fast, and so on.
>
> Now add one the check for destroy to avoid the possible panic.
>
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>

Looks good,

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

This is introduced by commit 87b60cfacf9f17cf71933c6e33b.
Please add proper Fixes tag next time.

Thanks.

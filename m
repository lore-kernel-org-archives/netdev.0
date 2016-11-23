From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net 1/1] net sched filters: fix filter handle ID in tfilter_notify_chain()
Date: Tue, 22 Nov 2016 20:09:17 -0800
Message-ID: <CAM_iQpXP1Rq+p_EjwTaVkS5BNXsBh7kstTxT2o7bkSxvXPy8Yw@mail.gmail.com>
References: <1479866224-12285-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:36355 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755360AbcKWEJi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 23:09:38 -0500
Received: by mail-io0-f181.google.com with SMTP id x94so4114758ioi.3
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 20:09:37 -0800 (PST)
In-Reply-To: <1479866224-12285-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2016 at 5:57 PM, Roman Mashak <mrv@mojatatu.com> wrote:
> Should pass valid filter handle, not the netlink flags.
>
> Fixes: 30a391a13ab92 ("net sched filters: pass netlink message flags in event notification")
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Reported-by: Cong Wang <xiyou.wangcong@gmail.com>

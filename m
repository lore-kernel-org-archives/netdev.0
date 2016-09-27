From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next V2] net/sched: pkt_cls: change tc actions order
 to be as the user sets
Date: Tue, 27 Sep 2016 09:29:23 -0700
Message-ID: <CAM_iQpWXpTsXUewMSv5VBFrq1yLgy5du+Lrszi_FQGZi=zQSPw@mail.gmail.com>
References: <1474963791-3717-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34368 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752565AbcI0Q3p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 12:29:45 -0400
Received: by mail-io0-f193.google.com with SMTP id y139so1198200ioy.1
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 09:29:44 -0700 (PDT)
In-Reply-To: <1474963791-3717-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 27, 2016 at 1:09 AM, Hadar Hen Zion <hadarh@mellanox.com> wrote:
> Currently the created tc actions list is reversed against the order
> set by the user.
> Change the actions list order to be the same as was set by the user.
>
> This patch doesn't affect dump actions behavior.
> For dumping, action->order parameter is used so the list order doesn't
> matter.
>
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>


Thanks for updating changelog!

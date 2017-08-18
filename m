From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net] net: sched: fix p_filter_chain check in tcf_chain_flush
Date: Fri, 18 Aug 2017 09:59:51 -0700
Message-ID: <CAM_iQpUQC9-CEc4DeWdst+wx0n1pF3MFSnWiG4HO4bEeUyYq7w@mail.gmail.com>
References: <20170818081043.2130-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34095 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750812AbdHRRAM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 13:00:12 -0400
Received: by mail-pg0-f67.google.com with SMTP id i12so574606pgr.1
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 10:00:12 -0700 (PDT)
In-Reply-To: <20170818081043.2130-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 18, 2017 at 1:10 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> The dereference before check is wrong and leads to an oops when
> p_filter_chain is NULL. The check needs to be done on the pointer to
> prevent NULL dereference.
>
> Fixes: f93e1cdcf42c ("net/sched: fix filter flushing")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

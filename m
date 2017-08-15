From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net_sched: reset pointers to tcf blocks in classful
 qdiscs' destructors
Date: Tue, 15 Aug 2017 16:00:48 +0200
Message-ID: <20170815140048.GA1836@nanopsycho>
References: <150280412126.717517.16274927544808177918.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34421 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751965AbdHOOAx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 10:00:53 -0400
Received: by mail-wm0-f66.google.com with SMTP id x64so1568650wmg.1
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 07:00:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150280412126.717517.16274927544808177918.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 15, 2017 at 03:35:21PM CEST, khlebnikov@yandex-team.ru wrote:
>Traffic filters could keep direct pointers to classes in classful qdisc,
>thus qdisc destruction first removes all filters before freeing classes.
>Class destruction methods also tries to free attached filters but now
>this isn't safe because tcf_block_put() unlike to tcf_destroy_chain()
>cannot be called second time.
>
>This patch set class->block to NULL after first tcf_block_put() and
>turn second call into no-op.
>
>Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>Fixes: 6529eaba33f0 ("net: sched: introduce tcf block infractructure")

Acked-by: Jiri Pirko <jiri@mellanox.com>

Thanks!

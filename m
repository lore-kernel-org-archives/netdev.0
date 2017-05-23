From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next 2/2] net/sched: fix filter flushing
Date: Mon, 22 May 2017 22:40:49 -0700
Message-ID: <CAM_iQpVgoLm21ZKJr-i7my3zb4wgepHZBrYc18KVXtCqONeQ4A@mail.gmail.com>
References: <20170520130132.1626-1-jiri@resnulli.us> <20170520130132.1626-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Simon Horman <simon.horman@netronome.com>, mlxsw@mellanox.com,
        Colin King <colin.king@canonical.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35327 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761091AbdEWFlL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 01:41:11 -0400
Received: by mail-wm0-f41.google.com with SMTP id b84so12323834wmh.0
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 22:41:10 -0700 (PDT)
In-Reply-To: <20170520130132.1626-2-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 20, 2017 at 6:01 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> When user instructs to remove all filters from chain, we cannot destroy
> the chain as other actions may hold a reference. Also the put in errout
> would try to destroy it again. So instead, just walk the chain and remove
> all existing filters.
>
> Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

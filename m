From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next 3/4] net: sched: convert cls_flower->egress_dev
 users to tc_setup_cb_egdev infra
Date: Tue, 10 Oct 2017 23:08:23 +0300
Message-ID: <CAJ3xEMh0cM3FszEjKNNe3aWTjHoDxof9GURgUSMy5k3iSTLg2g@mail.gmail.com>
References: <20171010073016.3682-1-jiri@resnulli.us> <20171010073016.3682-4-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        mlxsw <mlxsw@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>,
        Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:45632 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935022AbdJJUIY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 16:08:24 -0400
Received: by mail-oi0-f66.google.com with SMTP id f66so2969137oib.2
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 13:08:24 -0700 (PDT)
In-Reply-To: <20171010073016.3682-4-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 10:30 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> The only user of cls_flower->egress_dev is mlx5.

but nfp supports decap action offload too and from the flower code
stand point, I guess they are both the same, right? how does it work
there?

Or.

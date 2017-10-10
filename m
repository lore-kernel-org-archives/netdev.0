From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 3/4] net: sched: convert cls_flower->egress_dev
 users to tc_setup_cb_egdev infra
Date: Tue, 10 Oct 2017 23:16:09 +0200
Message-ID: <20171010211609.GK2033@nanopsycho>
References: <20171010073016.3682-1-jiri@resnulli.us>
 <20171010073016.3682-4-jiri@resnulli.us>
 <CAJ3xEMh0cM3FszEjKNNe3aWTjHoDxof9GURgUSMy5k3iSTLg2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <simon.horman@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        mlxsw <mlxsw@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:52314 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932583AbdJJVQL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 17:16:11 -0400
Received: by mail-wm0-f67.google.com with SMTP id k4so675539wmc.1
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 14:16:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMh0cM3FszEjKNNe3aWTjHoDxof9GURgUSMy5k3iSTLg2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 10, 2017 at 10:08:23PM CEST, gerlitz.or@gmail.com wrote:
>On Tue, Oct 10, 2017 at 10:30 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> The only user of cls_flower->egress_dev is mlx5.
>
>but nfp supports decap action offload too and from the flower code
>stand point, I guess they are both the same, right? how does it work
>there?

Apparently they don't use cls_flower->egress_dev.

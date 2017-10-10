From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next 3/4] net: sched: convert cls_flower->egress_dev
 users to tc_setup_cb_egdev infra
Date: Wed, 11 Oct 2017 00:47:19 +0300
Message-ID: <CAJ3xEMhHf8_bV_EFs2T44ikskm5dzHgiV0GhbW1UZneyO=d8jw@mail.gmail.com>
References: <20171010073016.3682-1-jiri@resnulli.us> <20171010073016.3682-4-jiri@resnulli.us>
 <CAJ3xEMh0cM3FszEjKNNe3aWTjHoDxof9GURgUSMy5k3iSTLg2g@mail.gmail.com> <20171010211609.GK2033@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Simon Horman <simon.horman@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        mlxsw <mlxsw@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>,
        John Hurley <john.hurley@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:50436 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756410AbdJJVrU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 17:47:20 -0400
Received: by mail-oi0-f67.google.com with SMTP id q4so30052091oic.7
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 14:47:20 -0700 (PDT)
In-Reply-To: <20171010211609.GK2033@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 11, 2017 at 12:16 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Oct 10, 2017 at 10:08:23PM CEST, gerlitz.or@gmail.com wrote:
>>On Tue, Oct 10, 2017 at 10:30 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> The only user of cls_flower->egress_dev is mlx5.
>>
>>but nfp supports decap action offload too and from the flower code
>>stand point, I guess they are both the same, right? how does it work
>>there?
>
> Apparently they don't use cls_flower->egress_dev.

John, can you elaborate on that, how do you manage to get away from
that practice?

From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net: sched: set xt_tgchk_param par.nft_compat with
 false in ipt_init_target
Date: Mon, 7 Aug 2017 14:03:15 -0700
Message-ID: <CAM_iQpUT8CMdz1sgBaVS+7drzPPFp10APOHiKPib8oNq7kPsFg@mail.gmail.com>
References: <985e6cb7c94f0014096ebca47e1efd74e022dc8d.1501932779.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:36600 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751589AbdHGVDg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 17:03:36 -0400
Received: by mail-ua0-f194.google.com with SMTP id w45so865446uac.3
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 14:03:36 -0700 (PDT)
In-Reply-To: <985e6cb7c94f0014096ebca47e1efd74e022dc8d.1501932779.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 5, 2017 at 4:32 AM, Xin Long <lucien.xin@gmail.com> wrote:
> Commit 55917a21d0cc ("netfilter: x_tables: add context to know if
> extension runs from nft_compat") introduced a member nft_compat to
> xt_tgchk_param structure.
>
> But it didn't set it's value for ipt_init_target. With unexpected
> value in par.nft_compat, it may return unexpected result in some
> target's checkentry.
>
> This patch is to set par.nft_compat with false in ipt_init_target.

It's time to set all these fields to 0 and only initialize those non-zero
fields, in case we will add more fields in the future.

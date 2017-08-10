From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] net: sched: set xt_tgchk_param par.nft_compat as
 0 in ipt_init_target
Date: Wed, 09 Aug 2017 22:47:21 -0700 (PDT)
Message-ID: <20170809.224721.929007871688762915.davem@davemloft.net>
References: <35173c1e2c6272d137c24706186f1641496943ce.1502273719.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51930 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751373AbdHJFrW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 01:47:22 -0400
In-Reply-To: <35173c1e2c6272d137c24706186f1641496943ce.1502273719.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed,  9 Aug 2017 18:15:19 +0800

> Commit 55917a21d0cc ("netfilter: x_tables: add context to know if
> extension runs from nft_compat") introduced a member nft_compat to
> xt_tgchk_param structure.
> 
> But it didn't set it's value for ipt_init_target. With unexpected
> value in par.nft_compat, it may return unexpected result in some
> target's checkentry.
> 
> This patch is to set all it's fields as 0 and only initialize the
> non-zero fields in ipt_init_target.
> 
> v1->v2:
>   As Wang Cong's suggestion, fix it by setting all it's fields as
>   0 and only initializing the non-zero fields.
> 
> Fixes: 55917a21d0cc ("netfilter: x_tables: add context to know if extension runs from nft_compat")
> Suggested-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable.

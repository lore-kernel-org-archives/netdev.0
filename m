From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net sched ife action: Introduce skb
 tcindex metadata encap decap
Date: Sat, 17 Sep 2016 09:43:48 -0400 (EDT)
Message-ID: <20160917.094348.1695664050052204019.davem@davemloft.net>
References: <1473936594-5152-1-git-send-email-jhs@emojatatu.com>
        <1473936594-5152-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, xiyou.wangcong@gmail.com,
        netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59950 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751134AbcIQNn6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 09:43:58 -0400
In-Reply-To: <1473936594-5152-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Thu, 15 Sep 2016 06:49:54 -0400

> +static int __init ifetc_index_init_module(void)
> +{
> +	pr_emerg("Loaded IFE tc_index\n");
 ...
> +static void __exit ifetc_index_cleanup_module(void)
> +{
> +	pr_emerg("Unloaded IFE tc_index\n");

This looks like some leftover debugging, please remove.

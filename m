From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: rps: Add the rfs_needed check when
 record flow hash
Date: Thu, 25 May 2017 13:11:41 -0400 (EDT)
Message-ID: <20170525.131141.1106125565617394205.davem@davemloft.net>
References: <1495611359-118199-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59474 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763381AbdEYRLn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 13:11:43 -0400
In-Reply-To: <1495611359-118199-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@vip.163.com
Date: Wed, 24 May 2017 15:35:59 +0800

>  
> +static inline void sock_rps_record_flow_hash(__u32 hash)
> +{
> +#ifdef CONFIG_RPS
> +	if (static_key_false(&rfs_needed))
> +		_sock_rps_record_flow_hash(hash);
> +#endif
> +}
> +

This is no longer used.

If you have some plans to use it in another context, you absolutely _MUST_
post this change inside of a patch series that adds the new user as well.

Otherwise it is impossible to determine the correctness and
appropriateness of your changes.

Thanks.

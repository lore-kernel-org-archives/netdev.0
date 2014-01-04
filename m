From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] cls_cgroup: fix memory leak in cls_cgroup_change()
Date: Fri, 03 Jan 2014 21:02:09 -0500 (EST)
Message-ID: <20140103.210209.901517258686201934.davem@davemloft.net>
References: <1388776399-27657-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754271AbaADCCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 21:02:13 -0500
In-Reply-To: <1388776399-27657-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri,  3 Jan 2014 11:13:19 -0800

> Fix it by moving allocation to ->init().
> 
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

I don't understand how the memory leak can happen, please explain
it in your commit message.

Also:

>  {
> +	struct cls_cgroup_head *head;
> +	head = kzalloc(sizeof(*head), GFP_KERNEL);

Please add an empty line between local variable declarations
and code.

Thanks.

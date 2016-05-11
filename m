From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v2 0/6] net sched: Fix broken late binding of
 actions
Date: Tue, 10 May 2016 23:50:55 -0400 (EDT)
Message-ID: <20160510.235055.441910590125653514.davem@davemloft.net>
References: <1462913371-9699-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jiri@resnulli.us,
	alexander.duyck@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45576 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157AbcEKDu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 23:50:59 -0400
In-Reply-To: <1462913371-9699-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Tue, 10 May 2016 16:49:25 -0400

> Some actions were broken in allowing for late binding of actions.
> Late binding workflow is as follows:
> a) create an action and provide all necessary parameters for it
> Optionally provide an index or let the kernel give you one.
> Example:
> sudo tc actions add action police rate 1kbit burst 90k drop index 1
> 
> b) later on bind to the pre-created action from a filter definition
> by merely specifying the index.
> Example:
> sudo tc filter add dev lo parent ffff: protocol ip prio 8 \
> u32 match ip src 127.0.0.8/32 flowid 1:8 action police index 1

Series applied, thanks Jamal.

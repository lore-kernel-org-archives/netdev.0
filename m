From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] act_ipt: fix a bind refcnt leak
Date: Wed, 15 Jun 2016 12:32:09 -0700 (PDT)
Message-ID: <20160615.123209.1306379017589501351.davem@davemloft.net>
References: <1465850654-27128-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33475 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578AbcFOTcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 15:32:10 -0400
In-Reply-To: <1465850654-27128-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 13 Jun 2016 13:44:14 -0700

> And avoid calling tcf_hash_check() twice.
> 
> Fixes: a57f19d30b2d ("net sched: ipt action fix late binding")
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, and queued up for -stable.

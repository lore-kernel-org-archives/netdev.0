From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net v2] act_police: fix a crash during removal
Date: Tue, 07 Jun 2016 16:39:37 -0700 (PDT)
Message-ID: <20160607.163937.912604117468317513.davem@davemloft.net>
References: <1465232070-7844-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59083 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751627AbcFGXjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 19:39:39 -0400
In-Reply-To: <1465232070-7844-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon,  6 Jun 2016 09:54:30 -0700

> The police action is using its own code to initialize tcf hash
> info, which makes us to forgot to initialize a->hinfo correctly.
> Fix this by calling the helper function tcf_hash_create() directly.
> 
> This patch fixed the following crash:
 ...
> Fixes: ddf97ccdd7cb ("net_sched: add network namespace support for tc actions")
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-net] ipv6: Use hlist_for_each_entry_rcu_bh() in
 ipv6_chk_same_addr()
Date: Tue, 01 Nov 2011 04:39:38 -0400 (EDT)
Message-ID: <20111101.043938.1065811675133329291.davem@davemloft.net>
References: <1320125455-25222-1-git-send-email-roy.qing.li@gmail.com>
	<20111101.035323.458528114788135444.davem@davemloft.net>
	<CAJFZqHxTh4kxaqiKWNGuu7vV_VvMx8jH-qXBr+dj7YNOitDrpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329Ab1KAIjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 04:39:43 -0400
In-Reply-To: <CAJFZqHxTh4kxaqiKWNGuu7vV_VvMx8jH-qXBr+dj7YNOitDrpQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing Li <roy.qing.li@gmail.com>
Date: Tue, 1 Nov 2011 16:33:49 +0800

> Yes, But I think the code readable is not good,

It is wasteful to add multiple BH disables and RCU memory
barriers in code paths where it is not necessary.

Your patch fixes no real bug, and adds a regression.

From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] fq_codel: fix return value of fq_codel_drop()
Date: Wed, 15 Jul 2015 21:36:57 -0700 (PDT)
Message-ID: <20150715.213657.2085137317071991288.davem@davemloft.net>
References: <1436898118-30804-1-git-send-email-xiyou.wangcong@gmail.com>
	<1436898118-30804-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752833AbbGPEg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 00:36:58 -0400
In-Reply-To: <1436898118-30804-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 14 Jul 2015 11:21:58 -0700

> The ->drop() is supposed to return the number of bytes it dropped,
> however fq_codel_drop() returns the index of the flow where it drops
> a packet from.
> 
> Fix this by introducing a helper to wrap fq_codel_drop().
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>

Applied.

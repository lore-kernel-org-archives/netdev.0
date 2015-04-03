From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ip6mr: call del_timer_sync() in ip6mr_free_table()
Date: Thu, 02 Apr 2015 20:53:38 -0400 (EDT)
Message-ID: <20150402.205338.1131469367270163229.davem@davemloft.net>
References: <1427824907-13331-1-git-send-email-xiyou.wangcong@gmail.com>
	<1427824907-13331-3-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021AbbDCAxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 20:53:40 -0400
In-Reply-To: <1427824907-13331-3-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 31 Mar 2015 11:01:47 -0700

> We need to wait for the flying timers, since we
> are going to free the mrtable right after it.
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.

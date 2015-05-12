From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netns: return RTM_NEWNSID instead of RTM_GETNSID
 on a get
Date: Tue, 12 May 2015 18:54:15 -0400 (EDT)
Message-ID: <20150512.185415.1721060646638002254.davem@davemloft.net>
References: <1431352651-31921-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbbELWyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 18:54:16 -0400
In-Reply-To: <1431352651-31921-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 11 May 2015 15:57:31 +0200

> Usually, RTM_NEWxxx is returned on a get (same as a dump).
> 
> Fixes: 0c7aecd4bde4 ("netns: add rtnl cmd to add and get peer netns ids")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> 
> David, FYI, this patch will conflict with my last series on net-next.
> The prototype of rtnl_net_fill() has changed. In any problem, please let me
> know.

Applied, thanks Nicolas.

I'll sort out the conflict when I next do a merge, thanks for the heads
up.

From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv4: register igmp_notifier even when
 !CONFIG_PROC_FS
Date: Tue, 14 Jan 2014 15:04:18 -0800 (PST)
Message-ID: <20140114.150418.1635576593193924711.davem@davemloft.net>
References: <1389398985-16198-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org, kaber@trash.net
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbaANXET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 18:04:19 -0500
In-Reply-To: <1389398985-16198-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 10 Jan 2014 16:09:45 -0800

> We still need this notifier even when we don't config
> PROC_FS.
> 
> It should be rare to have a kernel without PROC_FS,
> so just for completeness.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

This looks a little ugly, but I can't suggest anything better.

Applied, thanks.

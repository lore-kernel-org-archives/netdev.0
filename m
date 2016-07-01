From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: fix mirrored packets checksum
Date: Fri, 01 Jul 2016 16:20:14 -0400 (EDT)
Message-ID: <20160701.162014.122571360002384184.davem@davemloft.net>
References: <1467306922-7086-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, tom@herbertland.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42864 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbcGAUUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 16:20:23 -0400
In-Reply-To: <1467306922-7086-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 30 Jun 2016 10:15:22 -0700

> Similar to commit 9b368814b336 ("net: fix bridge multicast packet checksum validation")
> we need to fixup the checksum for CHECKSUM_COMPLETE when
> pushing skb on RX path. Otherwise we get similar splats.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.

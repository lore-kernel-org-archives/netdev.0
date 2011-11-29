From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: remove useless codes in ipmr_device_event()
Date: Tue, 29 Nov 2011 18:32:19 -0500 (EST)
Message-ID: <20111129.183219.248794718877770002.davem@davemloft.net>
References: <1322125852-15395-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44495 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756278Ab1K2XcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 18:32:22 -0500
In-Reply-To: <1322125852-15395-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu, 24 Nov 2011 17:10:52 +0800

> From: RongQing.Li <roy.qing.li@gmail.com>
> 
> Commit 7dc00c82 added a 'notify' parameter for vif_delete() to
> distinguish whether to unregister the device.
> 
> When notify=1 means we does not need to unregister the device,
> so calling unregister_netdevice_many is useless.
> 
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>

I'll apply this, thanks.

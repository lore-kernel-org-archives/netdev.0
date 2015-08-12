From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: ipv4: increase dhcp inter device timeout
Date: Wed, 12 Aug 2015 16:40:41 -0700 (PDT)
Message-ID: <20150812.164041.1772250761467753718.davem@davemloft.net>
References: <1439373703-31620-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbbHLXkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 19:40:42 -0400
In-Reply-To: <1439373703-31620-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Wed, 12 Aug 2015 15:31:43 +0530

> When a system has multiple ethernet devices and during DHCP
> request (for using NFS), the system waits only for HZ/2 which is
> 500mS before switching to another interface for DHCP.
> 
> There are some routers (Ex: Trendnet routers) which responds to
> DHCP request at about 560mS. When the system has only one
> ethernet interface there is no issue as the timeout is 2S and the
> dev xid doesn't changes and only retries.
> 
> But when the system has multiple Ethernet like DRA74x with CPSW
> in dual EMAC mode, the DHCP response is dropped as the dev xid
> changes while shifting to the next device. So changing inter
> device timeout to HZ (which is 1S).
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied, thanks.

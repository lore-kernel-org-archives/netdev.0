From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] smsc911x: fix platform resource call during module
 unload
Date: Thu, 25 Dec 2008 16:44:09 -0800 (PST)
Message-ID: <20081225.164409.108388714.davem@davemloft.net>
References: <1229709930-19925-1-git-send-email-steve.glendinning@smsc.com>
	<1229709930-19925-2-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dfoley@telus.net, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56004
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752205AbYLZAoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 19:44:07 -0500
In-Reply-To: <1229709930-19925-2-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Fri, 19 Dec 2008 18:05:30 +0000

> This patch fixes a typo, the platform_get_resource calls in
> smsc911x_drv_remove are supposed to look the same as those in
> smsc911x_drv_probe.
> 
> Reported and fixed by dfoley@telus.net.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Also applied, thanks Steve.

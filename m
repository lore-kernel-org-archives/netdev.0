From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc75xx: fix jumbo frame support
Date: Fri, 29 Mar 2013 15:16:59 -0400 (EDT)
Message-ID: <20130329.151659.638890791929368860.davem@davemloft.net>
References: <1364474081-21918-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, philip.dawson@paconsulting.com
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756564Ab3C2TRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 15:17:00 -0400
In-Reply-To: <1364474081-21918-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@shawell.net>
Date: Thu, 28 Mar 2013 12:34:41 +0000

> This patch enables RX of jumbo frames for LAN7500.
> 
> Previously the driver would transmit jumbo frames succesfully but
> would drop received jumbo frames (incrementing the interface errors
> count).
> 
> With this patch applied the device can succesfully receive jumbo
> frames up to MTU 9000 (9014 bytes on the wire including ethernet
> header).
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>

Applied and queued up for -stable, thanks Steve.

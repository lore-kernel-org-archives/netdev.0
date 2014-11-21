From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vlan: Pass ethtool get_ts_info queries to
 real device.
Date: Fri, 21 Nov 2014 15:36:36 -0500 (EST)
Message-ID: <20141121.153636.1495548883679399605.davem@davemloft.net>
References: <1416575780-19132-1-git-send-email-richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stefan.sorensen@spectralink.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014AbaKUUgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 15:36:39 -0500
In-Reply-To: <1416575780-19132-1-git-send-email-richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Fri, 21 Nov 2014 14:16:20 +0100

> Commit a6111d3c "vlan: Pass SIOC[SG]HWTSTAMP ioctls to real device"
> intended to enable hardware time stamping on VLAN interfaces, but
> passing SIOCSHWTSTAMP is only half of the story. This patch adds
> the second half, by letting user space find out the time stamping
> capabilities of the device backing a VLAN interface.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Applied, thanks Richard.

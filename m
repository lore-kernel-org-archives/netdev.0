From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: fix the wake event
Date: Fri, 08 Jan 2016 21:51:11 -0500 (EST)
Message-ID: <20160108.215111.1162581442866830417.davem@davemloft.net>
References: <1394712342-15778-170-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754232AbcAICvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 21:51:14 -0500
In-Reply-To: <1394712342-15778-170-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 7 Jan 2016 17:12:17 +0800

> When the autosuspend is enabled and occurs before system suspend, we should
> wake the device before running system syspend. Then, we could change the wake
> event for system suspend. Otherwise, the device would resume the system when
> receiving any packet.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: fix deadlock in resume
Date: Fri, 31 Aug 2012 16:12:33 -0400 (EDT)
Message-ID: <20120831.161233.1367551762954796924.davem@davemloft.net>
References: <1346049698-10740-1-git-send-email-oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ming.lei@canonical.com, oneukum@suse.de,
	stable@kernel.org
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53166 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754997Ab2HaUMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 16:12:35 -0400
In-Reply-To: <1346049698-10740-1-git-send-email-oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: oliver@neukum.org
Date: Mon, 27 Aug 2012 08:41:38 +0200

> From: Oliver Neukum <oliver@neukum.org>
> 
> A usbnet device can share a multifunction device
> with a storage device. If the storage device is autoresumed
> the usbnet devices also needs to be autoresumed. Allocating
> memory with GFP_KERNEL can deadlock in this case.
> 
> This should go back into all kernels that have
> commit 65841fd5132c3941cdf5df09e70df3ed28323212
> That is 3.5
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>

Applied, thanks.

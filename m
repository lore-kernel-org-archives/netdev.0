From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] usbnet: Stop RX Q on MTU change
Date: Thu, 30 Jun 2016 09:10:58 -0400 (EDT)
Message-ID: <20160630.091058.1167326156765721140.davem@davemloft.net>
References: <57741c69.+XhberGLPTATRjgd%soohoon.lee@f5.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oneukum@suse.com
To: soohoon.lee@f5.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55867 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424AbcF3NL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 09:11:29 -0400
In-Reply-To: <57741c69.+XhberGLPTATRjgd%soohoon.lee@f5.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: soohoon.lee@f5.com
Date: Wed, 29 Jun 2016 15:07:21 -0400

> When MTU is changed unlink_urbs() flushes RX Q but mean while usbnet_bh()
> can fill up the Q at the same time.
> Depends on which HCD is down there unlink takes long time then the flush
> never ends.
> 
> Signed-off-by: Soohoon Lee <soohoon.lee@f5.com>
> Reviewed-by: Kimball Murray <kmurray@f5.com>

Applied.

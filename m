From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH usbnet v2.1] mtu change needs to stop RX
Date: Tue, 28 Jun 2016 05:14:38 -0400 (EDT)
Message-ID: <20160628.051438.2119909907582286496.davem@davemloft.net>
References: <8aa35a23da7141bba3549841e66e55db@seaexchmbx01.olympus.F5Net.com>
	<1466728213238.68985@f5.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oneukum@suse.com, netdev@vger.kernel.org
To: Soohoon.Lee@f5.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53825 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173AbcF1JPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 05:15:07 -0400
In-Reply-To: <1466728213238.68985@f5.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soohoon Lee <Soohoon.Lee@f5.com>
Date: Fri, 24 Jun 2016 00:30:16 +0000

> 
> When MTU is changed unlink_urbs() flushes RX Q but mean while usbnet_bh() can fill up the Q at the same time.
> Depends on which HCD is down there unlink takes long time then the flush never ends.
> 
> Signed-off-by: Soohoon Lee <soohoon.lee@f5.com>
> Reviewed-by: Kimball Murray <kmurray@f5.com>

This patch is mangled by your email client, the TAB characters have been
converted into spaces.

Please do not resubmit this patah until you can successfully email the
patch to yourself and apply it cleanly.

Also, your subject line should be formatted like:

	[PATCH net v2.x] usbnet: ....

Thanks.

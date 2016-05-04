From: David Miller <davem@davemloft.net>
Subject: Re: [patch] usbnet/smsc75xx: silence uninitialized variable warning
Date: Wed, 04 May 2016 16:59:29 -0400 (EDT)
Message-ID: <20160504.165929.10411595050574763.davem@davemloft.net>
References: <20160504062102.GE22064@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbcEDU7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 16:59:31 -0400
In-Reply-To: <20160504062102.GE22064@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 4 May 2016 09:21:02 +0300

> If the fn() calls fail then "buf" is uninitialized.  Just return early
> in that situation.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.

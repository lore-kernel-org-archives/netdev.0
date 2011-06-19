From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/usb: Add Samsung Kalmia driver for Samsung
 GT-B3730
Date: Sun, 19 Jun 2011 15:57:55 -0700 (PDT)
Message-ID: <20110619.155755.1854488306547854947.davem@davemloft.net>
References: <201106141146.19097.oneukum@suse.de>
	<1308519957-28860-1-git-send-email-marius@kotsbak.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	marius@kotsbak.com
To: marius.kotsbak@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37567 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754989Ab1FSW7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 18:59:12 -0400
In-Reply-To: <1308519957-28860-1-git-send-email-marius@kotsbak.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Marius B. Kotsbak" <marius.kotsbak@gmail.com>
Date: Sun, 19 Jun 2011 23:45:56 +0200

> Introducing driver for the network port of Samsung Kalmia based USB LTE modems.
> It has also an ACM interface that previous patches associates with the "option"
> module. To access those interfaces, the modem must first be switched from modem
> mode using a tool like usb_modeswitch.
> 
> As the proprietary protocol has been discovered by watching the MS Windows driver
> behavior, there might be errors in the protocol handling, but stable and fast
> connection has been established for hours with Norwegian operator NetCom that
> distributes this modem with their LTE/4G subscription.
> 
> More and updated information about how to use this driver is available here:
> 
> http://www.draisberghof.de/usb_modeswitch/bb/viewtopic.php?t=465
> https://github.com/mkotsbak/Samsung-GT-B3730-linux-driver
> 
> Signed-off-by: Marius B. Kotsbak <marius@kotsbak.com>

Please submit only one patch for adding a new driver.

Adding a second patch that fixes the driver in various ways is
just noise, put those fixes into this one initial patch instead.

Thanks.

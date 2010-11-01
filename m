From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: runtime pm: fix usb_autopm_get_interface
 failure
Date: Mon, 01 Nov 2010 06:42:27 -0700 (PDT)
Message-ID: <20101101.064227.71104061.davem@davemloft.net>
References: <1288190703-3154-1-git-send-email-tom.leiming@gmail.com>
	<20101101.064052.226792945.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oliver@neukum.org,
	dbrownell@users.sourceforge.net, gregkh@suse.de,
	ben@decadent.org.uk, joe@perches.com, andy.shevchenko@gmail.com,
	stable@kernel.org
To: tom.leiming@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54598
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757937Ab0KANmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 09:42:04 -0400
In-Reply-To: <20101101.064052.226792945.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 01 Nov 2010 06:40:52 -0700 (PDT)

> Applied, thanks.

Actually, I had to revert, this doesn't compile when CONFIG_PM is
disabled:

drivers/net/usb/usbnet.c: In function 'usbnet_probe':
drivers/net/usb/usbnet.c:1284:3: error: implicit declaration of function 'pm_runtime_enable'

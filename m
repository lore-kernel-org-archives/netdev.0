From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] USB Network driver infrastructure: Fix leak when
 usb_autopm_get_interface() returns less than zero in kevent().
Date: Sun, 13 Feb 2011 11:21:32 -0800 (PST)
Message-ID: <20110213.112132.58449746.davem@davemloft.net>
References: <alpine.LNX.2.00.1102102152450.26035@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, gregkh@suse.de,
	dbrownell@users.sourceforge.net, dhollis@davehollis.com
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1102102152450.26035@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Thu, 10 Feb 2011 21:58:45 +0100 (CET)

> We'll leak the memory allocated to 'urb' in 
> drivers/net/usb/usbnet.c:kevent() when we 'goto fail_lowmem' and the 'urb' 
> variable goes out of scope while still completely unused.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Applied.

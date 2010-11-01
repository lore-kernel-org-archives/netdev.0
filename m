From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: runtime pm: fix usb_autopm_get_interface
 failure
Date: Mon, 01 Nov 2010 06:40:52 -0700 (PDT)
Message-ID: <20101101.064052.226792945.davem@davemloft.net>
References: <1288190703-3154-1-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oliver@neukum.org,
	dbrownell@users.sourceforge.net, gregkh@suse.de,
	ben@decadent.org.uk, joe@perches.com, andy.shevchenko@gmail.com,
	stable@kernel.org
To: tom.leiming@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47745
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756235Ab0KANk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 09:40:28 -0400
In-Reply-To: <1288190703-3154-1-git-send-email-tom.leiming@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: tom.leiming@gmail.com
Date: Wed, 27 Oct 2010 22:45:03 +0800

> From: Ming Lei <tom.leiming@gmail.com>
> 
> Since usbnet already took usb runtime pm, we have to
> enable runtime pm for usb interface of usbnet, otherwise
> usb_autopm_get_interface may return failure and cause
> 'ifconfig usb0 up' failed if USB_SUSPEND(RUNTIME_PM) is
> enabled.
> 
> Cc: David Brownell <dbrownell@users.sourceforge.net>
> Cc: Greg Kroah-Hartman <gregkh@suse.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Ben Hutchings <ben@decadent.org.uk>
> Cc: Joe Perches <joe@perches.com>
> Cc: Oliver Neukum <oliver@neukum.org>
> Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
> Cc: stable@kernel.org
> Signed-off-by: Ming Lei <tom.leiming@gmail.com>

Applied, thanks.

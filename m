From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] NET: usb: Adding URB_ZERO_PACKET flag to usbnet.c
Date: Tue, 06 Apr 2010 19:50:37 -0700 (PDT)
Message-ID: <20100406.195037.247530407.davem@davemloft.net>
References: <1270599787.8900.8.camel@Linuxdev4-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbrownell@users.sourceforge.net, rfiler@sierrawireless.com,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: epasheva@sierrawireless.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47023
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750921Ab0DGCug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 22:50:36 -0400
In-Reply-To: <1270599787.8900.8.camel@Linuxdev4-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elina Pasheva <epasheva@sierrawireless.com>
Date: Tue, 6 Apr 2010 17:23:07 -0700

> Subject: [PATCH 1/1] NET: usb: Adding URB_ZERO_PACKET flag to usbnet.c
> From: Elina Pasheva <epasheva@sierrawireless.com>
> This patch adds setting of the urb transfer flag URB_ZERO_PACKET  before
> submitting an urb for drivers that have requested it (by advertising flag
> FLAG_SEND_ZLP).
> The modification is in usbnet.c function usbnet_start_xmit().
> This patch only adds the zero length flag.
> A subsequent patch will address the buggy code we found when devices do not
> advertise FLAG_SEND_ZLP in which case there is a possibility of transferring
> packets with non-deterministic length.
> 
> This patch has been tested on kernel-2.6.34-rc3.
> This patch has been checked against net-2.6 tree.
> Signed-off-by: Elina Pasheva <epasheva@sierrawireless.com>
> Signed-off-by: Rory Filer <rfiler@sierrawireless.com>

Applied to net-next-2.6, thanks.

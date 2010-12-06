From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 1/2] usbnet: changes for upcoming cdc_ncm driver
Date: Mon, 06 Dec 2010 12:59:23 -0800 (PST)
Message-ID: <20101206.125923.39169615.davem@davemloft.net>
References: <1291109008-3613-1-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	oliver@neukum.org, yauheni.kaliuta@nokia.com, balbi@ti.com,
	sjur.brandeland@stericsson.com, alexey.orishko@stericsson.com
To: alexey.orishko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44495
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752388Ab0LFU64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 15:58:56 -0500
In-Reply-To: <1291109008-3613-1-git-send-email-alexey.orishko@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Orishko <alexey.orishko@gmail.com>
Date: Tue, 30 Nov 2010 12:23:27 +0300

> Changes:
> include/linux/usb/usbnet.h:
> - a new flag to indicate driver's capability to accumulate IP packets in Tx
>  direction and extract several packets from single skb in Rx direction.
> drivers/net/usb/usbnet.c:
> - the procedure of counting packets in usbnet was updated due to the
>  accumulating of IP packets in the driver
> - no short packets are sent if indicated by the flag in driver_info
>  structure
> 
> Signed-off-by: Alexey Orishko <alexey.orishko@stericsson.com>

Applied.

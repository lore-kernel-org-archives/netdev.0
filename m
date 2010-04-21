From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: Fix possible NULL pointer dereference in ems_usb.c
Date: Wed, 21 Apr 2010 16:15:21 -0700 (PDT)
Message-ID: <20100421.161521.102460178.davem@davemloft.net>
References: <20100420.180501.08643239.davem@davemloft.net>
	<20100421101805.GA1995@bluebox.local>
	<4BCED326.3060000@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hjk@linutronix.de, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50431
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754033Ab0DUXPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 19:15:17 -0400
In-Reply-To: <4BCED326.3060000@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Wed, 21 Apr 2010 12:27:50 +0200

>> Subject: [PATCH] can: Fix possible NULL pointer dereference in ems_usb.c
>> 
>> In ems_usb_probe(), a pointer is dereferenced after making sure it is NULL...
>> 
>> This patch replaces netdev->dev.parent with &intf->dev in dev_err() calls to
>> avoid this.
>> 
>> Signed-off-by: "Hans J. Koch" <hjk@linutronix.de>
 ...
> Acked-by: Wolfgang Grandegger <wg@grandegger.com>

Applied, thanks.

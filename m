From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: remove direct access to urb->status
Date: Mon, 05 Jul 2010 19:08:40 -0700 (PDT)
Message-ID: <20100705.190840.27788010.davem@davemloft.net>
References: <201007021558.25774.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53017
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757517Ab0GFCI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 22:08:26 -0400
In-Reply-To: <201007021558.25774.oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>
Date: Fri, 2 Jul 2010 15:58:25 +0200

> From a2e8da61490cba876b1b4814c4832822527c43dd Mon Sep 17 00:00:00 2001
> From: Oliver Neukum <oliver@neukum.org>
> Date: Fri, 2 Jul 2010 15:51:55 +0200
> Subject: [PATCH] usbnet: remove direct access to urb->status
> 
> USB drivers should not use urb->status directly because
> it is scheduled to become a parameter. This does the conversion
> for drivers/net/usb
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>

Applied.

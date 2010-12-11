From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] vxge: transmit timeout deadlock
Date: Fri, 10 Dec 2010 16:09:10 -0800 (PST)
Message-ID: <20101210.160910.43039931.davem@davemloft.net>
References: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
	<1292025782-16372-4-git-send-email-jon.mason@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sivakumar.subramani@exar.com,
	sreenivasa.honnur@exar.com, ram.vepa@exar.com
To: jon.mason@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53873
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757273Ab0LKAIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:08:42 -0500
In-Reply-To: <1292025782-16372-4-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@exar.com>
Date: Fri, 10 Dec 2010 18:02:59 -0600

> Use a workqueue to handle the device reset during a transmit timeout, as
> there can be a deadlock during bringup.  Also, set the netif carrier off
> before the watchdog reset is started to prevent the timeout from
> reoccurring while still processing the first.
> 
> Signed-off-by: Jon Mason <jon.mason@exar.com>
> Signed-off-by: Ram Vepa <ram.vepa@exar.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: Changes in queue allocation and freeing
Date: Mon, 15 Nov 2010 10:58:22 -0800 (PST)
Message-ID: <20101115.105822.233710935.davem@davemloft.net>
References: <alpine.DEB.1.00.1011091240470.18565@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49157
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932749Ab0KOS55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 13:57:57 -0500
In-Reply-To: <alpine.DEB.1.00.1011091240470.18565@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 9 Nov 2010 12:47:26 -0800 (PST)

> Changes to both RX and TX queue allocation.  In both cases allocate
> in alloc_netdev_mq and free in free_netdev.  For RX the reference
> couting also changed, the device reference count can now be used.

Both applied, with the comment removal added as promised.

I assume you'll spin a new version of the XPS patches
against this?

Thanks!

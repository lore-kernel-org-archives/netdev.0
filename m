From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2.6.30-rc4] usbnet: CDC EEM support (v5)
Date: Mon, 04 May 2009 12:01:54 -0700 (PDT)
Message-ID: <20090504.120154.15328003.davem@davemloft.net>
References: <200905041200.10196.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, omar.oberthur@gmail.com,
	linux-usb@vger.kernel.org
To: david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35172
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754328AbZEDTCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 15:02:00 -0400
In-Reply-To: <200905041200.10196.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <david-b@pacbell.net>
Date: Mon, 4 May 2009 12:00:10 -0700

> This introduces a CDC Ethernet Emulation Model (EEM) host side
> driver to support USB EEM devices.
> 
> EEM is different from the Ethernet Control Model (ECM) currently
> supported by the "CDC Ethernet" driver.  One key difference is
> that it doesn't require of USB interface alternate settings to
> manage interface state; some maldesigned hardware can't handle
> that part of USB.  It also avoids a separate USB interface for
> control and status updates.
> 
> [ dbrownell@users.sourceforge.net: fix skb leaks, add rx packet
> checks, improve fault handling, EEM conformance updates, cleanup ]
> 
> Signed-off-by: Omar Laazimani <omar.oberthur@gmail.com>
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>

Applied, thanks.

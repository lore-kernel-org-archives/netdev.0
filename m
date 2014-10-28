From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH net 0/3] cdc-ether: handle promiscuous mode
Date: Tue, 28 Oct 2014 22:10:25 +0100
Message-ID: <1414530625.29018.1.camel@linux-0dmf.site>
References: <1414172582-30844-1-git-send-email-olivier.blin@softathome.com>
	 <20141028.154926.273240718595756465.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: olivier.blin@softathome.com, netdev@vger.kernel.org,
	hayeswang@realtek.com, bjorn@mork.no
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53975 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750982AbaJ1VVz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2014 17:21:55 -0400
In-Reply-To: <20141028.154926.273240718595756465.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-28 at 15:49 -0400, David Miller wrote:
> From: Olivier Blin <olivier.blin@softathome.com>
> Date: Fri, 24 Oct 2014 19:42:59 +0200
> 
> > Since kernel 3.16, my Lenovo USB network adapters (RTL8153) using
> > cdc-ether are not working anymore in a bridge.
> > 
> > This is due to commit c472ab68ad67db23c9907a27649b7dc0899b61f9, which
> > resets the packet filter when the device is bound.
> > 
> > The default packet filter set by cdc-ether does not include
> > promiscuous, while the adapter seemed to have promiscuous enabled by
> > default.
> > 
> > This patch series allows to support promiscuous mode for cdc-ether, by
> > hooking into set_rx_mode.
> > 
> > Incidentally, maybe this device should be handled by the r8152 driver,
> > but this patch series is still nice for other adapters.
> 
> Can a usbnet expert please review this series?

Acked-by: Oliver Neukum <oneukum@suse.de>

	Regards
		Oliver

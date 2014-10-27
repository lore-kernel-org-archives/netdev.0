From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH net 0/3] cdc-ether: handle promiscuous mode
Date: Mon, 27 Oct 2014 11:02:28 +0100
Message-ID: <1414404148.26910.0.camel@linux-0dmf.site>
References: <1414172582-30844-1-git-send-email-olivier.blin@softathome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hayeswang@realtek.com, bjorn@mork.no,
	davem@davemloft.net
To: Olivier Blin <olivier.blin@softathome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48585 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751184AbaJ0KCT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 06:02:19 -0400
In-Reply-To: <1414172582-30844-1-git-send-email-olivier.blin@softathome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-24 at 19:42 +0200, Olivier Blin wrote:
> Hi,
> 
> Since kernel 3.16, my Lenovo USB network adapters (RTL8153) using
> cdc-ether are not working anymore in a bridge.
> 
> This is due to commit c472ab68ad67db23c9907a27649b7dc0899b61f9, which
> resets the packet filter when the device is bound.
> 
> The default packet filter set by cdc-ether does not include
> promiscuous, while the adapter seemed to have promiscuous enabled by
> default.
> 
> This patch series allows to support promiscuous mode for cdc-ether, by
> hooking into set_rx_mode.
> 
> Incidentally, maybe this device should be handled by the r8152 driver,
> but this patch series is still nice for other adapters.

Acked-by: Oliver Neukum <oneukum@suse.de>

	Regards
		Oliver

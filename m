From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Move eth_mac_addr and eth_change_mtu
Date: Fri, 11 Jul 2003 14:23:30 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711182330.GC16037@gtf.org>
References: <20030711181946.GG20424@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
Content-Disposition: inline
In-Reply-To: <20030711181946.GG20424@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 11, 2003 at 07:19:46PM +0100, Matthew Wilcox wrote:
> Move eth_mac_addr() and eth_change_mtu() from drivers/net/net_init.c
> to net/ethernet/eth.c

Why?  It's not used outside of net_init.c AFAICS.

And even so, don't you want to export those symbols?

	Jeff

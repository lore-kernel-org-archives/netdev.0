From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH] Move eth_mac_addr and eth_change_mtu
Date: Fri, 11 Jul 2003 19:25:30 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711182530.GH20424@parcelfarce.linux.theplanet.co.uk>
References: <20030711181946.GG20424@parcelfarce.linux.theplanet.co.uk> <20030711182330.GC16037@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20030711182330.GC16037@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 11, 2003 at 02:23:30PM -0400, Jeff Garzik wrote:
> On Fri, Jul 11, 2003 at 07:19:46PM +0100, Matthew Wilcox wrote:
> > Move eth_mac_addr() and eth_change_mtu() from drivers/net/net_init.c
> > to net/ethernet/eth.c
> 
> Why?  It's not used outside of net_init.c AFAICS.

Preparation for the next stage of netdev_ops

> And even so, don't you want to export those symbols?

Yep, you're right, I'll need to do that too.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk

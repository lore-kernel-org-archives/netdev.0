From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 6/7] net: Add vbus_enet driver
Date: Mon, 3 Aug 2009 13:19:27 -0700
Message-ID: <20090803131927.6f653556@nehalam>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>
	<20090803171801.17268.93846.stgit@dev.haskins.net>
	<20090803113030.3092d5b0@nehalam>
	<4A77443D.9020105@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752559AbZHCUTd@vger.kernel.org>
In-Reply-To: <4A77443D.9020105@novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 03 Aug 2009 16:10:37 -0400
Gregory Haskins <ghaskins@novell.com> wrote:

> Stephen Hemminger wrote:
> > On Mon, 03 Aug 2009 13:18:02 -0400
> > Gregory Haskins <ghaskins@novell.com> wrote:
> > 
> >> +
> >> +static const struct net_device_ops vbus_enet_netdev_ops = {
> >> +	.ndo_open          = vbus_enet_open,
> >> +	.ndo_stop          = vbus_enet_stop,
> >> +	.ndo_set_config    = vbus_enet_config,
> >> +	.ndo_start_xmit    = vbus_enet_tx_start,
> >> +	.ndo_change_mtu	   = vbus_enet_change_mtu,
> >> +	.ndo_tx_timeout    = vbus_enet_timeout,
> >> +};
> > 
> > 
> > Missing 
> > 	.ndo_set_mac_address = eth_mac_addr,
> > 	.ndo_validate_addr   = eth_validate_addr,
> > 
> 
> Ack.
> 
> > Also, should have change_mtu.
> 
> note that I do have .ndo_change_mtu.  I assume this is what you are
> referring to and just missed it.  If there is something else I need
> there, let me know.

If you don't have a change_mtu, then MTU is unlimited. Can the device
handle 64K or larger transfers?

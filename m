From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 6/7] net: Add vbus_enet driver
Date: Mon, 3 Aug 2009 13:29:27 -0700
Message-ID: <20090803132927.2818fee2@nehalam>
References: <20090803171030.17268.26962.stgit@dev.haskins.net>
	<20090803171801.17268.93846.stgit@dev.haskins.net>
	<20090803113030.3092d5b0@nehalam>
	<4A77443D.9020105@novell.com>
	<20090803131927.6f653556@nehalam>
	<4A77476A.1030001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <ghaskins@novell.com>,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52589 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753964AbZHCU3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Aug 2009 16:29:32 -0400
In-Reply-To: <4A77476A.1030001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 Aug 2009 16:24:10 -0400
Gregory Haskins <gregory.haskins@gmail.com> wrote:

> Stephen Hemminger wrote:
> > On Mon, 03 Aug 2009 16:10:37 -0400
> > Gregory Haskins <ghaskins@novell.com> wrote:
> > 
> >> Stephen Hemminger wrote:
> >>> On Mon, 03 Aug 2009 13:18:02 -0400
> >>> Gregory Haskins <ghaskins@novell.com> wrote:
> >>>
> >>>> +
> >>>> +static const struct net_device_ops vbus_enet_netdev_ops = {
> >>>> +	.ndo_open          = vbus_enet_open,
> >>>> +	.ndo_stop          = vbus_enet_stop,
> >>>> +	.ndo_set_config    = vbus_enet_config,
> >>>> +	.ndo_start_xmit    = vbus_enet_tx_start,
> >>>> +	.ndo_change_mtu	   = vbus_enet_change_mtu,
> >>>> +	.ndo_tx_timeout    = vbus_enet_timeout,
> >>>> +};
> >>>
> >>> Missing 
> >>> 	.ndo_set_mac_address = eth_mac_addr,
> >>> 	.ndo_validate_addr   = eth_validate_addr,
> >>>
> >> Ack.
> >>
> >>> Also, should have change_mtu.
> >> note that I do have .ndo_change_mtu.  I assume this is what you are
> >> referring to and just missed it.  If there is something else I need
> >> there, let me know.
> > 
> > If you don't have a change_mtu, then MTU is unlimited.
> 
> Is "change_mtu" different from .ndo_change_mtu" on the ndo struct?
> That's whats confusing me, as I have the .ndo one already.  Is there
> something else I need in addition, or should I be ok as is?

Never mind, it is same as .ndo_change_mtu

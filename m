From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ANNOUNCEMENT] NET: usb: sierra_net.c driver
Date: Mon, 29 Mar 2010 01:44:02 +0100
Message-ID: <1269823442.8653.261.camel@localhost>
References: <1269652919.30630.1.camel@Linuxdev3>
	 <1269791821.11714.202.camel@localhost.localdomain>
	 <4BAFAA2C.8060604@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Rory Filer <rfiler@sierrawireless.com>, netdev@vger.kernel.org,
	linux-usb <linux-usb@vger.kernel.org>
To: sclark46@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:9319 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755451Ab0C2AoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 20:44:12 -0400
In-Reply-To: <4BAFAA2C.8060604@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-03-28 at 15:12 -0400, Stephen Clark wrote:
> On 03/28/2010 11:57 AM, Marcel Holtmann wrote:
> > Hi Elina,
> >
> >> +static const struct driver_info sierra_net_info_68A3 = {
> >> +	.description = "Sierra Wireless USB-Ethernet Modem",
> >> +	.flags = FLAG_ETHER | FLAG_SEND_ZLP,
> >> +	.bind = sierra_net_bind,
> >> +	.unbind = sierra_net_unbind,
> >> +	.status = sierra_net_status,
> >> +	.rx_fixup = sierra_net_rx_fixup,
> >> +	.tx_fixup = sierra_net_tx_fixup,
> >> +	.data = (unsigned long)&sierra_net_info_data_68A3,
> >> +};
> >
> > the FLAG_ETHER is wrong here. Please use FLAG_WWAN to clearly mark these
> > interfaces.
> >
> > Otherwise we have wrong DEVTYPE uevent assignments and userspace will
> > treat them as real Ethernet cards. And that should not happen. As a nice
> Why shouldn't that happen if they look like NIC cards?
[...]

This information is important for management interfaces.  The user
doesn't care what your device looks like at the kernel level - they know
it's a wireless broadband device and they expect to see a device
labelled as such in Network Manager or whatever they use.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


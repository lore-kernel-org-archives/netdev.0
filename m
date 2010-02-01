From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: bluetooth-2.6 2010-01-30
Date: Sun, 31 Jan 2010 23:35:38 -0800 (PST)
Message-ID: <20100131.233538.125549914.davem@davemloft.net>
References: <cover.1264859950.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52382
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752703Ab0BAHfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 02:35:24 -0500
In-Reply-To: <cover.1264859950.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Sat, 30 Jan 2010 06:08:43 -0800

> this includes two L2CAP fixes. One for a memory leak and another one for
> a double free.
> 
> For Bluetooth PCMCIA cards a BUG_ON caused a few issues when we have
> shared interrupts. So revert this and put a clear comment in the source
> that this is what we actually want.
> 
> The Bluetooth HID fix for raw reports has a big diffstat, but the logical
> change is small. By accident we send the reports on the interrupt channel
> and the original test device seems to cope with that. Devices that follow
> the specification more closer will break. The right thing is to use the
> control channel. This is similar to what is done via USB.
> 
> And by request from Luis, include the driver for Atheros Bluetooth chipset
> AR3011. It is a new driver and by itself small and self contained. If you
> feel that it should not be merged, then let me know and I redo this
> patchset.

Pulled, thanks Marcel.

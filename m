From: David Miller <davem@davemloft.net>
Subject: Re: DM9000: Wake on LAN support
Date: Wed, 11 Nov 2009 19:58:40 -0800 (PST)
Message-ID: <20091111.195840.197444472.davem@davemloft.net>
References: <20091110172224.215538042@fluff.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@simtec.co.uk
To: ben@simtec.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53698
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757410AbZKLD6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 22:58:13 -0500
In-Reply-To: <20091110172224.215538042@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Dooks <ben@simtec.co.uk>
Date: Tue, 10 Nov 2009 17:22:24 +0000

> Add support for Wake on LAN (WOL) reception and waking the device up from
> this signal via the ethtool interface. Currently we are only supporting
> the magic-packet variant of wakeup.
> 
> WOL is enabled by specifying a second interrupt resource to the driver
> which indicates where the interrupt for the WOL is being signalled. This
> then enables the necessary ethtool calls to leave the device in a state
> to receive WOL frames when going into suspend.
> 
> Signed-off-by: Ben Dooks <ben@simtec.co.uk>
> Signed-off-by: Simtec Linux Team <linux@simtec.co.uk>

Applied to net-next-2.6

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/9] atm: propagate atm_dev signal carrier to
 LOWER_UP of netdevice
Date: Fri, 09 Jul 2010 00:10:24 -0700 (PDT)
Message-ID: <20100709.001024.52175570.davem@davemloft.net>
References: <1278658538-6769-1-git-send-email-karl@hiramoto.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil
To: karl@hiramoto.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54275
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751959Ab0GIHKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 03:10:10 -0400
In-Reply-To: <1278658538-6769-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karl Hiramoto <karl@hiramoto.org>
Date: Fri,  9 Jul 2010 08:55:29 +0200

> Use atm_dev notifier chain  instead of callback function pointer in struct vcc.
> In drivers/usb/atm call atm_dev_signal_change().
> 
> In userspace it's helpful to know if a network device has a carrier signal.
> Often it is monitored via netlink.  This patchset allows a way for the
> struct atm_dev drivers to pass carrier on/off to the netdevice.
> 
> For DSL, carrier is on when the line has reached showtime state.
> 
> Currently this patchset only propagates the changes to br2684 vccs,
> as this is the only type of hardware I have to test.
> 
> If you prefer git you can pull from:
> git://github.com/karlhiramoto/linux-2.6.git atm-v5

All applied, thanks Karl.

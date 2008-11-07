From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver updates for 2.6.29
Date: Fri, 07 Nov 2008 01:35:14 -0800 (PST)
Message-ID: <20081107.013514.105616478.davem@davemloft.net>
References: <20081106065059.GA19202@havoc.gtf.org>
	<20081106.221330.181959128.davem@davemloft.net>
	<4913F778.7000206@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43431
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750998AbYKGJfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 04:35:16 -0500
In-Reply-To: <4913F778.7000206@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 07 Nov 2008 03:08:24 -0500

> David Miller wrote:
> > From: Jeff Garzik <jeff@garzik.org>
> > Date: Thu, 6 Nov 2008 01:50:59 -0500
> > 
> >> Please pull from 'davem-next' branch of
> >> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-next
> >>
> >> to receive the following updates:
> > drivers/net/usb/usbnet.c: In function 'usbnet_suspend':
> > drivers/net/usb/usbnet.c:1357: error: 'struct usb_device' has no member named 'auto_pm'
> > Please fix this up and send me another pull request.
> 
> hmmm, builds for me on x86 and x86-64.
> 
> <looks>  are you building with CONFIG_PM disabled, perhaps?  I'll try that build next...

Yes, in fact CONFIG_PM is always disabled on sparc64.

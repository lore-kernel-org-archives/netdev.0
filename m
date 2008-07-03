From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 26/39]: netdev: netdev_priv() can now be sane again.
Date: Thu, 03 Jul 2008 04:26:14 -0700 (PDT)
Message-ID: <20080703.042614.244608628.davem@davemloft.net>
References: <20080703.000446.125029084.davem@davemloft.net>
	<m3tzf7nrd7.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vinay@linux.vnet.ibm.com,
	krkumar2@in.ibm.com, mchan@broadcom.com, Matheos.Worku@Sun.COM,
	linux-wireless@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50895
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754362AbYGCMCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 08:02:24 -0400
In-Reply-To: <m3tzf7nrd7.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Thu, 03 Jul 2008 13:23:32 +0200

> David Miller <davem@davemloft.net> writes:
> 
> > The private area of a netdev is now at a fixed offset once more.
> >
> > Unfortunately, some assumptions that netdev_priv() == netdev->priv
> > crept back into the tree.  In particular this happened in the
> > loopback driver.
> 
> Perhaps the netdev_priv() should be renamed to avoid confusion?

If all drivers call netdev_priv(), there is no confusion :)

I plan to rename dev->priv to dev->_priv and fix all the fallout.

From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] e1000e: register pm_qos request on
 hardware activation
Date: Mon, 02 Aug 2010 21:21:13 -0700 (PDT)
Message-ID: <20100802.212113.173851850.davem@davemloft.net>
References: <20100803002622.4179.31850.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	florian@mickler.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60602
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750879Ab0HCEUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 00:20:55 -0400
In-Reply-To: <20100803002622.4179.31850.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 02 Aug 2010 17:27:00 -0700

> From: Florian Mickler <florian@mickler.org>
> 
> The pm_qos_add_request call has to register the pm_qos request with the pm_qos
> susbsystem before first use of the pm_qos request via
> pm_qos_update_request.
> 
> As pm_qos changed to use plists there is no benefit in registering and
> unregistering the pm_qos request on ifup/ifdown and thus we move the
> registering into e1000_open and the unregistering in e1000_close.
> 
> This fixes the following warning:
 ...
> Signed-off-by: Florian Mickler <florian@mickler.org>
> Tested-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

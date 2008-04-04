From: David Miller <davem@davemloft.net>
Subject: Re: [patch] NET: remove support for Davicom 9102 from the Tulip
 driver
Date: Fri, 04 Apr 2008 15:28:29 -0700 (PDT)
Message-ID: <20080404.152829.131540045.davem@davemloft.net>
References: <47F69FBE.3020308@garzik.org>
	<20080404.150249.132264075.davem@davemloft.net>
	<47F6A659.7000100@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mroos@linux.ee, cebbert@redhat.com, netdev@vger.kernel.org,
	grundler@parisc-linux.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43419
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751734AbYDDW22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 18:28:28 -0400
In-Reply-To: <47F6A659.7000100@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 04 Apr 2008 18:06:17 -0400

> In this case, should dmfe be retrieving the MAC address via
> 
> 	addr = of_get_property(dp, "local-mac-address", &len);
> 
> as tulip is doing?

That's right.

> One thing that seems quite obvious is that dmfe is missing all the 
> CONFIG_SPARC goodies that tulip has.

Yep.

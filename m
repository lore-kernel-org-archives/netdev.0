From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 checked] typhoon: Use request_firmware()
Date: Mon, 02 Mar 2009 22:15:25 -0800 (PST)
Message-ID: <20090302.221525.237789900.davem@davemloft.net>
References: <20090302.015315.181629191.davem@davemloft.net>
	<1236059062.4207.11.camel@localhost.localdomain>
	<1236059356.4207.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org
To: dave@thedillows.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46987
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751280AbZCCGPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 01:15:43 -0500
In-Reply-To: <1236059356.4207.14.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Dillow <dave@thedillows.org>
Date: Tue, 03 Mar 2009 00:49:16 -0500

> typhoon: repair firmware loading
> 
> The conversion to avoid using pci_alloc_consistent() broke the firmware
> load process, as well as added an order-4 kmalloc and doubled the memory
> usage of the firmware image. Go back to loading a page at a time.
> 
> Also, since the user can now give us utter garbage for firmware, do a
> cursory validation so we don't try to load just anything.
> 
> Signed-off-by: David Dillow <dave@thedillows.org>

Applied, thanks David.

From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] e1000/e1000e/igb/ixgb: do not use
 netif_wake_queue un-necessarily
Date: Wed, 22 Apr 2009 00:48:40 -0700 (PDT)
Message-ID: <20090422.004840.142633147.davem@davemloft.net>
References: <20090422044153.22980.31231.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57510
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751442AbZDVHss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 03:48:48 -0400
In-Reply-To: <20090422044153.22980.31231.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 21 Apr 2009 21:42:05 -0700

> It was pointed out that the Intel wired ethernet drivers do not need to
> wake the tx queue since netif_carrier_on/off will take care of the qdisc
> management in order to guarantee the correct handling of the transmit
> routine enable state.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied to net-next-2.6, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: fix for 82599 errata marking UDP
 checksum errors
Date: Sun, 26 Jul 2009 20:21:54 -0700 (PDT)
Message-ID: <20090726.202154.00452824.davem@davemloft.net>
References: <20090724040031.30202.1531.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48566
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755847AbZG0DVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 23:21:47 -0400
In-Reply-To: <20090724040031.30202.1531.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 23 Jul 2009 21:00:39 -0700

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> There is an 82599 errata that UDP frames with a zero checksum are
> incorrectly marked as checksum invalid by the hardware.  This was
> leading to misleading hw_csum_rx_error counts. This patch adds a
> test around this counter increase for this condition.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.

But I wonder.   When you compute a checksum, and it's zero,
you have to use the complement as the checksum value.  How
does that relate to the problem being tackled here?


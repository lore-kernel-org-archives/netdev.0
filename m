From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000e: enable/disable ASPM L0s and L1 and ERT
 according to hardware errata
Date: Tue, 27 Apr 2010 10:18:37 -0700 (PDT)
Message-ID: <20100427.101837.58441162.davem@davemloft.net>
References: <20100427133232.25490.92973.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, mjg@redhat.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50152
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754221Ab0D0RSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 13:18:31 -0400
In-Reply-To: <20100427133232.25490.92973.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 27 Apr 2010 06:33:04 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Prompted by a previous patch submitted by Matthew Garret <mjg@redhat.com>,
> further digging into errata documentation reveals the current enabling or
> disabling of ASPM L0s and L1 states for certain parts supported by this
> driver are incorrect.  82571 and 82572 should always disable L1.  For
> standard frames, 82573/82574/82583 can enable L1 but L0s must be disabled,
> and for jumbo frames 82573/82574 must disable L1.  This allows for some
> parts to enable L1 in certain configurations leading to better power
> savings.
> 
> Also according to the same errata, Early Receive (ERT) should be disabled
> on 82573 when using jumbo frames.
> 
> Cc: Matthew Garret <mjg@redhat.com>
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

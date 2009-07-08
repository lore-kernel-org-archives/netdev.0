From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] igb: set lan id prior to configuring phy
Date: Tue, 07 Jul 2009 19:13:50 -0700 (PDT)
Message-ID: <20090707.191350.87304778.davem@davemloft.net>
References: <20090707230149.20967.85805.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33079
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751715AbZGHCNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 22:13:47 -0400
In-Reply-To: <20090707230149.20967.85805.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 07 Jul 2009 16:01:55 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The igb driver was defaulting to using the lock for pci-e function 0 for
> all of the phys due to the fact that the lan id was not being set prior to
> initialization.  This change makes it so that the function id is set prior
> to checking for the phy id.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied to net-2.6

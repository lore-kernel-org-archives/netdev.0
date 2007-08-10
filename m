From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] ethtool: Add LRO support
Date: Fri, 10 Aug 2007 02:28:42 -0700 (PDT)
Message-ID: <20070810.022842.85409561.davem@davemloft.net>
References: <20070809164117.9907.23351.stgit@localhost.localdomain>
	<46BC2504.9010400@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	ossthema@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42704
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758904AbXHJJ2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 05:28:42 -0400
In-Reply-To: <46BC2504.9010400@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 10 Aug 2007 04:42:44 -0400

> I'll code this up, along with the associated generic helpers 
> (net/core/ethtool.c), if there are no objections.

No objections except I would give the driver private it's
own set of flags.

Otherwise the number of bits you choose is arbitrary and
the potential for mistakes is definitely there is you mix
the two uses.

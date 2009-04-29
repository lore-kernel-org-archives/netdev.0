From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] ixgbe: enable HW RSC for 82599
Date: Tue, 28 Apr 2009 17:54:46 -0700 (PDT)
Message-ID: <20090428.175446.191949653.davem@davemloft.net>
References: <20090428084236.32710.14750.stgit@localhost.localdomain>
	<20090428.015535.42660210.davem@davemloft.net>
	<alpine.WNT.2.00.0904281648300.5352@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, alexander.h.duyck@intel.com
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50869
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751294AbZD2Ayx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 20:54:53 -0400
In-Reply-To: <alpine.WNT.2.00.0904281648300.5352@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Tue, 28 Apr 2009 17:12:10 -0700 (Pacific Daylight Time)

> ah, you're right, but this features enables our new hardware that can do 
> LRO in hardware, and then GRO can work on top of it if necessary.  We 
> wanted some way to turn it off and overloaded the LRO flag to do so.

That ugly.  And the kernel is going to turn this off on you
when the user enables either forwarding or bridging.

> FYI This is not a TOE, it just recognizes a flow and will pack data frames 
> together in a list of descriptors, which the driver then hands to the 
> stack as a large receive.

I know what it is.

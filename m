From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] ixgbe: Fix return of invalid txq
Date: Wed, 03 Feb 2010 19:17:32 -0800 (PST)
Message-ID: <20100203.191732.188341750.davem@davemloft.net>
References: <20100203231224.15352.27988.stgit@localhost.localdomain>
	<20100203231309.15352.12337.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, krkumar2@in.ibm.com,
	jesse.brandeburg@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44761
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753976Ab0BDDRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 22:17:19 -0500
In-Reply-To: <20100203231309.15352.12337.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 03 Feb 2010 15:13:10 -0800

> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> a developer had complained of getting lots of warnings:
> 
> "eth16 selects TX queue 98, but real number of TX queues is 64"
> 
> http://www.mail-archive.com/e1000-devel@lists.sourceforge.net/msg02200.html
> 
> As there was no follow up on that bug, I am submitting this
> patch assuming that the other return points will not return
> invalid txq's, and also that this fixes the bug (not tested).
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

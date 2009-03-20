From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/3] ixgbe: Fixup the watchdog interrupt
 scheduling on 82599
Date: Fri, 20 Mar 2009 01:32:10 -0700 (PDT)
Message-ID: <20090320.013210.108262229.davem@davemloft.net>
References: <20090319112328.11957.63213.stgit@lost.foo-projects.org>
	<20090319112404.11957.31387.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55687
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756570AbZCTIcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 04:32:23 -0400
In-Reply-To: <20090319112404.11957.31387.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Mar 2009 04:24:04 -0700

> The watchdog will schedule an interrupt to help make sure queues are
> cleaned in the case when an interrupt is missed, most likely due to very
> high load.  On 82599, there are extra interrupt registers to account for
> the larger number of MSI-X vectors (64 total for 82599 vs. 18 total for
> 82598).  These must be taken into account when performing this operation in
> the watchdog.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

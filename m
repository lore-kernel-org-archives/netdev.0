From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/9] ixgbe: Fix 82598 MSI-X allocation on systems with
 more than 8 CPU cores
Date: Thu, 02 Apr 2009 01:15:42 -0700 (PDT)
Message-ID: <20090402.011542.23565948.davem@davemloft.net>
References: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
	<20090401073405.3749.98186.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60310
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756772AbZDBIPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:15:54 -0400
In-Reply-To: <20090401073405.3749.98186.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 01 Apr 2009 00:34:05 -0700

> MSI-X allocation broke after the 82599 merge on systems with more than 8
> CPU cores.  82598 drops back into MSI mode, which isn't sufficient to run
> full, efficient 10G line rate.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

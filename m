From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/9] ixgbe: Patch to fix driver panic while freeing up
 tx & rx resources
Date: Thu, 02 Apr 2009 01:15:56 -0700 (PDT)
Message-ID: <20090402.011556.00039325.davem@davemloft.net>
References: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
	<20090401073444.3749.94296.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60319
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758671AbZDBIQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:16:08 -0400
In-Reply-To: <20090401073444.3749.94296.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 01 Apr 2009 00:34:44 -0700

> When network interface is made active we were not handling the error
> scenarios properly to clean up rx & tx resources which might result in
> a driver panic.
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

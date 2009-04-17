From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] e1000e: fix bug in restart queue logic
Date: Fri, 17 Apr 2009 01:10:47 -0700 (PDT)
Message-ID: <20090417.011047.145821866.davem@davemloft.net>
References: <20090417025928.19671.88859.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40458
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753761AbZDQIKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 04:10:55 -0400
In-Reply-To: <20090417025928.19671.88859.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 16 Apr 2009 19:59:28 -0700

> If the e1000e transmit cleanup inner loop exited early, then
> cleaned might not be true.  This could cause tx hangs or other
> badness.  Use count to track the total number of descriptors
> cleaned instead of basing a tx queue restart off of a temporary
> working state variable.
> 
> This code now makes the flow the same for e1000/e1000e/igb/ixgbe
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

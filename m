From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/3] ixgb and e1000: Use new function for
 copybreak tests
Date: Fri, 14 May 2010 03:14:50 -0700 (PDT)
Message-ID: <20100514.031450.45911891.davem@davemloft.net>
References: <20100514012425.30457.23799.stgit@localhost.localdomain>
	<20100514012615.30457.37881.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, joe@perches.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34682
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758869Ab0ENKOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 06:14:42 -0400
In-Reply-To: <20100514012615.30457.37881.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 13 May 2010 18:26:17 -0700

> From: Joe Perches <joe@perches.com>
> 
> There appears to be an off-by-1 defect in the maximum packet size
> copied when copybreak is speified in these modules.
> 
> The copybreak module params are specified as:
> "Maximum size of packet that is copied to a new buffer on receive"
> 
> The tests are changed from "< copybreak" to "<= copybreak"
> and moved into new static functions for readability.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

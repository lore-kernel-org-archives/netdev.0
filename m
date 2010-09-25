From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbevf: Refactor ring parameter re-size
Date: Fri, 24 Sep 2010 22:43:44 -0700 (PDT)
Message-ID: <20100924.224344.68137693.davem@davemloft.net>
References: <20100923224543.13046.68372.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52900
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751869Ab0IYFnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Sep 2010 01:43:24 -0400
In-Reply-To: <20100923224543.13046.68372.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 23 Sep 2010 15:46:25 -0700

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> The function to resize the Tx/Rx rings had the potential to
> dereference a NULL pointer and the code would attempt to resize
> the Tx ring even if the Rx ring allocation had failed.  This
> would cause some confusion in the return code semantics.  Fixed
> up to just unwind the allocations if any of them fail and return
> an error.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks!

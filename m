From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/2] ixgbe: fix bug when EITR=0 causing no
 writebacks
Date: Tue, 27 Apr 2010 12:56:05 -0700 (PDT)
Message-ID: <20100427.125605.124069593.davem@davemloft.net>
References: <20100427113651.24431.9221.stgit@localhost.localdomain>
	<20100427113739.24431.46358.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49602
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756795Ab0D0T4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 15:56:00 -0400
In-Reply-To: <20100427113739.24431.46358.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 27 Apr 2010 04:37:41 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> writebacks can be held indefinitely by hardware if EITR=0, when
> combined with TXDCTL.WTHRESH=8.  When EITR=0, WTHRESH should be
> set back to zero.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

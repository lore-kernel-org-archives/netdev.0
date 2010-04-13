From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] e1000e: use static params to save stack
 space
Date: Tue, 13 Apr 2010 02:59:30 -0700 (PDT)
Message-ID: <20100413.025930.261419141.davem@davemloft.net>
References: <20100409205044.32158.23239.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49680
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752448Ab0DMJ70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 05:59:26 -0400
In-Reply-To: <20100409205044.32158.23239.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 09 Apr 2010 13:51:09 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> used a modified checkstack to get the 56 number
> (normally checkstack wouldn't show this low a value)
> 
> checkstack before:
> 0x0000012f e1000e_check_options [e1000e]:               272
> 
> after:
> 0x0000012f e1000e_check_options [e1000e]:                56
> 
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

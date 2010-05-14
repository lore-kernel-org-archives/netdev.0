From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] e1000: fix WARN_ON with mac-vlan
Date: Fri, 14 May 2010 03:14:39 -0700 (PDT)
Message-ID: <20100514.031439.58415470.davem@davemloft.net>
References: <20100514012425.30457.23799.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, jpirko@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34672
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753870Ab0ENKOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 06:14:31 -0400
In-Reply-To: <20100514012425.30457.23799.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 13 May 2010 18:25:33 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> When adding more than 14 mac-vlan adapters on e1000 the driver
> would fire a WARN_ON when adding the 15th.  The WARN_ON in this
> case is completely un-necessary, as the code below the WARN_ON is
> directly handling the value the WARN_ON triggered on.
> 
> CC: Jiri Pirko <jpirko@redhat.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

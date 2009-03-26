From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/4] e1000e: fix close interrupt race
Date: Thu, 26 Mar 2009 01:12:30 -0700 (PDT)
Message-ID: <20090326.011230.190740024.davem@davemloft.net>
References: <20090326080503.30401.71355.stgit@lost.foo-projects.org>
	<20090326080541.30401.83097.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com, alan@lxorguk.ukuu.org.uk
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47476
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756154AbZCZIMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 04:12:43 -0400
In-Reply-To: <20090326080541.30401.83097.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 26 Mar 2009 01:05:41 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> As noticed by Alan Cox, it is possible for e1000e to exit its interrupt
> handler or NAPI with interrupts enabled even when the driver is unloading or
> being configured administratively down.
> 
> fix related to fix for: http://bugzilla.kernel.org/show_bug.cgi?id=12876
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

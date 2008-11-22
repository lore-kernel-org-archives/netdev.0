From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 01/14] e1000e: disable correctable errors for
 quad ports while going to D3
Date: Fri, 21 Nov 2008 16:49:17 -0800 (PST)
Message-ID: <20081121.164917.112963763.davem@davemloft.net>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36959
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754646AbYKVAtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:49:18 -0500
In-Reply-To: <20081121185859.32313.42332.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 21 Nov 2008 10:59:00 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> There has been an issue seen with the pci-e quad port adapters that will
> cause them to generate a pci-e correctable error on some system while
> transitioning to D3.
> 
> Since no action is needed on this correctable error the simplest solution
> is to mask off the reporting of correctable errors.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

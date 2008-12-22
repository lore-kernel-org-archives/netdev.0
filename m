From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 1/3] net: fix DCB setstate to return
 success/failure
Date: Sun, 21 Dec 2008 20:10:05 -0800 (PST)
Message-ID: <20081221.201005.24296811.davem@davemloft.net>
References: <20081220001438.5908.23307.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	donald.c.skidmore@intel.com, eric.w.multanen@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38044
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752621AbYLVEKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2008 23:10:03 -0500
In-Reply-To: <20081220001438.5908.23307.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 19 Dec 2008 16:14:38 -0800

> Data Center Bridging (DCB) had no way to know if setstate had failed in the
> driver.  This patch enables dcb netlink code to handle the status for the DCB
> setstate interface.  Likewise it allows the driver to return a failed status
> if MSI-X isn't enabled.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Eric W Multanen <eric.w.multanen@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

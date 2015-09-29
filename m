From: David Miller <davem@davemloft.net>
Subject: Re: [net] i40e: fix VLAN inside VXLAN
Date: Mon, 28 Sep 2015 20:58:12 -0700 (PDT)
Message-ID: <20150928.205812.180990092088207225.davem@davemloft.net>
References: <1443464508-53806-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52876 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932337AbbI2D6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 23:58:13 -0400
In-Reply-To: <1443464508-53806-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 28 Sep 2015 11:21:48 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Previously to this patch, the hardware was removing
> VLAN tags from the inner header of VXLAN packets.  The
> hardware configuration can be changed to leave the
> packet alone since that is what the linux stack
> expects for this type of VLAN in VXLAN packet.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

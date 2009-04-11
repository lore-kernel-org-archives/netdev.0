From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ixgbe: only allow WOL for 82599 KX4 NIC
Date: Sat, 11 Apr 2009 01:44:23 -0700 (PDT)
Message-ID: <20090411.014423.216045494.davem@davemloft.net>
References: <20090408232031.8781.83459.stgit@localhost.localdomain>
	<20090408232050.8781.68279.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42498
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753101AbZDKIod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 04:44:33 -0400
In-Reply-To: <20090408232050.8781.68279.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 08 Apr 2009 16:20:50 -0700

> All NICs were reporting WOL support when only the KX4 NIC is capable of
> supporting WOL.  This patch adds a function to check for and exclude all
> non-WOL capable nics from enabling WOL in ethtool.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

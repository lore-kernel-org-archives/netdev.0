From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/3] ixgbe: Update link setup code to better
 support autonegotiation of speed
Date: Thu, 05 Feb 2009 23:55:00 -0800 (PST)
Message-ID: <20090205.235500.51162703.davem@davemloft.net>
References: <20090205013900.29241.77746.stgit@lost.foo-projects.org>
	<20090205013923.29241.30152.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35510
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752545AbZBFHzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 02:55:03 -0500
In-Reply-To: <20090205013923.29241.30152.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 04 Feb 2009 17:39:23 -0800

> The current code has some flaws in it when performing autonegotiation,
> especially on KX/KX4 links.  This patch updates the code to better handle
> the autonegotiation states on link setup.  The patch also removes a redundant
> link configuration call on driver load, and moves link configuration to
> the ->open() path.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

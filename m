From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 2/2] igb: re-order queues to support cleaner
 use of ivar on 82576
Date: Fri, 26 Dec 2008 01:34:19 -0800 (PST)
Message-ID: <20081226.013419.149926451.davem@davemloft.net>
References: <20081224223142.12176.9916.stgit@lost.foo-projects.org>
	<20081224223201.12176.17314.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60034
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753465AbYLZJeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 04:34:16 -0500
In-Reply-To: <20081224223201.12176.17314.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 24 Dec 2008 14:32:01 -0800

> The 82576 adapter orders the queues in pairs when virtualization is in use.
> The queue ordering previously conflicted with the ordering when sr-iov was
> enabled.  This new ordering allows a PF to allocate 2 queues without using
> any VF resources.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

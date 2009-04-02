From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net/igb: Fix kexec with igb (rev. 3)
Date: Thu, 02 Apr 2009 01:00:16 -0700 (PDT)
Message-ID: <20090402.010016.263453234.davem@davemloft.net>
References: <20090401072250.3461.90483.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, rjw@sisk.pl
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41768
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750955AbZDBIA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:00:28 -0400
In-Reply-To: <20090401072250.3461.90483.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 01 Apr 2009 00:23:50 -0700

> Impact: Fix
> 
> Yinghai Lu found one system with 82575EB where, in the kernel that is
> kexeced, probe igb failed with -2, the reason being that the adapter
> could not be brought back from D3 by the kexec kernel, most probably
> due to quirky hardware (it looks like the same behavior happened on
> forcedeth).
> 
> Prevent igb from putting the adapter into D3 during shutdown except
> when we going to power off the system.  For this purpose, seperate
> igb_shutdown() from igb_suspend() and use the appropriate PCI PM
> callbacks in both of them.
> 
> Signed-off-by: "Rafael J. Wysocki" <rjw@sisk.pl>
> Reported-by: Yinghai Lu <yinghai@kernel.org>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

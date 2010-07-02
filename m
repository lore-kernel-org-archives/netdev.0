From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 4/5] igb: correct link test not being run
 when link is down
Date: Thu, 01 Jul 2010 22:50:14 -0700 (PDT)
Message-ID: <20100701.225014.250825389.davem@davemloft.net>
References: <20100701233733.16171.4629.stgit@localhost.localdomain>
	<20100701233859.16171.45966.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49336
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755977Ab0GBFuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 01:50:01 -0400
In-Reply-To: <20100701233859.16171.45966.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 01 Jul 2010 16:39:01 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The igb online link test was always reporting pass because instead of
> checking for if_running it was checking for netif_carrier_ok.
> 
> This change corrects the test so that it is run if the interface is running
> instead of checking for netif carrier ok.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

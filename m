From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000e: do not initiate autonegotiation during
 OEM configuration
Date: Fri, 20 Nov 2009 13:54:19 -0800 (PST)
Message-ID: <20091120.135419.36258447.davem@davemloft.net>
References: <20091120001722.29775.22407.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45564
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754484AbZKTVyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 16:54:02 -0500
In-Reply-To: <20091120001722.29775.22407.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Nov 2009 16:17:30 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> When configuring the OEM bits in the PHY on 82577/82578, do not restart
> autonegotiation if the firmware is blocking it (e.g. when an IDE-R session
> is active) because the link must not go down.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

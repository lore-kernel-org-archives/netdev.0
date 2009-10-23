From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000e: reset the PHY on 82577/82578 when
 going to Sx
Date: Thu, 22 Oct 2009 21:22:28 -0700 (PDT)
Message-ID: <20091022.212228.193712916.davem@davemloft.net>
References: <20091023025247.6750.89717.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43226
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750759AbZJWEWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 00:22:05 -0400
In-Reply-To: <20091023025247.6750.89717.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 22 Oct 2009 19:53:00 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> The PHY on 82577/82578 parts needs a soft reset when transitioning to Sx
> state in order for the PHY write which disables gigabit speed to take
> effect.  Gigabit speed must be disabled in order for the PHY writes to
> registers on page 800 (the wakeup control registers) to work as expected
> otherwise the system might not wake via WoL.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

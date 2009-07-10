From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: Fix coexistence of FCoE and Flow
 Director in 82599
Date: Thu, 09 Jul 2009 17:17:20 -0700 (PDT)
Message-ID: <20090709.171720.66965956.davem@davemloft.net>
References: <20090709122944.962.54056.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, yi.zou@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60513
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750718AbZGJARR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 20:17:17 -0400
In-Reply-To: <20090709122944.962.54056.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 09 Jul 2009 05:29:50 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> Fix coexistence of Fiber Channel over Ethernet (FCoE) and Flow Director (FDIR)
> in 82599 and remove the disabling of FDIR when FCoE is enabled.
> 
> Currently, FDIR is turned off when FCoE is enabled under the assumption that
> FCoE is always enabled with DCB being turned on. However, FDIR does not have
> to be turned off all the time when FCoE is enabled since FCoE can be enabled
> without DCB being turned on, e.g., use link pause only. This patch makes sure
> that when DCB is turned on or off, FDIR is turned on or off correspondingly;
> and when FCoE is enabled, it does not disable FDIR, rather, it will have FDIR
> set up properly so FCoE and FDIR can coexist regardless of DCB being on or off.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

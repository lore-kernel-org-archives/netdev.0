From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: fix issues setting rx-usecs with legacy
 interrupts
Date: Thu, 13 Aug 2009 16:33:26 -0700 (PDT)
Message-ID: <20090813.163326.143691783.davem@davemloft.net>
References: <20090811231805.13967.1829.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, donald.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58782
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753519AbZHMXdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 19:33:16 -0400
In-Reply-To: <20090811231805.13967.1829.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 11 Aug 2009 16:18:14 -0700

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> Currently setting rx-usecs when the interface is in legacy interrupt
> mode it is not immediate.  We were only setting EITR for each MSIx
> vector and since this count would be zero for legacy mode it wasn't
> set until after a reset.  This patch corrects that by checking what
> mode we are in and then setting EITR accordingly.
> 
> Signed-off-by: Don Skidmore <donald.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied to net-2.6

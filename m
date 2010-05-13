From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 09/12] e1000e: fix checks for
 manageability enabled and management pass-through
Date: Wed, 12 May 2010 23:32:27 -0700 (PDT)
Message-ID: <20100512.233227.246539189.davem@davemloft.net>
References: <20100511005801.30827.50808.stgit@localhost.localdomain>
	<20100511010150.30827.4384.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45045
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754213Ab0EMGcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 02:32:19 -0400
In-Reply-To: <20100511010150.30827.4384.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 10 May 2010 18:01:51 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> The mac->arc_subsystem was being incorrectly used to flag whether or not
> manageability was enabled when it should only be used to state whether the
> ARC (Host interface) subsystem is available on a particular MAC _and_ only
> valid when any manageability is enabled. The ARC subsystem is currently
> only available on 80003es2lan and 82573 parts supported by the driver.
> 
> A new flag, has_fwsm, is introduced to be used when checking if
> manageability is enabled but only on parts that acutally have an FWSM
> register. While the above parts have an FWSM register, there are other
> parts that have FWSM but do not have support for the ARC subsystem,
> namely 82571/2 and ICHx/PCH.
> 
> And then there are parts that have manageability, but do not have either
> FWSM register or support for the ARC subsystem - these are 82574 and 82583.
> 
> For 80003es2lan, 82571/2/3 and ICH/PCH parts, this patch makes no
> functional changes, it only corrects the usage of the manageability flags.
> For 82574 and 82583, it fixes the incorrect accesses of the non-existent
> FWSM register and ARC subsystem as well as corrects the check for
> management pass-through.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: fix build error with FCOE_CONFIG
 without DCB_CONFIG
Date: Sun, 08 Aug 2010 20:03:35 -0700 (PDT)
Message-ID: <20100808.200335.26968781.davem@davemloft.net>
References: <20100809014538.595.63259.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	john.r.fastabend@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59374
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755266Ab0HIDDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 23:03:16 -0400
In-Reply-To: <20100809014538.595.63259.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sun, 08 Aug 2010 18:46:15 -0700

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> Building ixgbe without DCB_CONFIG and FCOE_CONFIG will cause
> a build error.  This resolves the build error by wrapping
> the fcoe.up in CONFIG_IXGBE_DCB ifdefs.
> 
> Also frames were being priority VLAN tagged even without DCB
> enabled.  This fixes this so that 8021Q priority tags are
> only added with DCB actually enabled.
> 
> Reported-by: divya <dipraksh@linux.vnet.ibm.com>
> Reported-by: Jon Mason <jon.mason@exar.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.

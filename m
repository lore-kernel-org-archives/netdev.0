From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] bonding: Do not call free_netdev for already
 registered device.
Date: Fri, 02 May 2008 17:51:34 -0700 (PDT)
Message-ID: <20080502.175134.217916824.davem@davemloft.net>
References: <12097757801056-git-send-email-fubar@us.ibm.com>
	<12097757822222-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, xemul@openvz.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34530
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760476AbYECAve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 20:51:34 -0400
In-Reply-To: <12097757822222-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri,  2 May 2008 17:49:37 -0700

> From: Pavel Emelyanov <xemul@openvz.org>
> 
> If the call to bond_create_sysfs_entry in bond_create fails, the
> proper rollback is to call unregister_netdevice, not free_netdev.
> Otherwise - kernel BUG at net/core/dev.c:4057!
> 
> Checked with artificial failures injected into bond_create_sysfs_entry.
> 
> Pavel's original patch modified by Jay Vosburgh to move code around
> for clarity (remove goto-hopping within the unwind block).
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Acked-by: David S. Miller <davem@davemloft.net>

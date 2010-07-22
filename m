From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] bonding: don't lock when
 copying/clearing VLAN list on slave
Date: Thu, 22 Jul 2010 14:13:05 -0700 (PDT)
Message-ID: <20100722.141305.04664571.davem@davemloft.net>
References: <1279750488-32611-1-git-send-email-fubar@us.ibm.com>
	<1279750488-32611-2-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47931
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759366Ab0GVVMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 17:12:48 -0400
In-Reply-To: <1279750488-32611-2-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Wed, 21 Jul 2010 15:14:48 -0700

> 	When copying VLAN information to or removing from a slave
> during slave addition or removal, the bonding code currently holds
> the bond->lock for write to prevent concurrent modification of the
> vlan_list / vlgrp.
> 
> 	This is unnecessary, as all of these operations occur under
> RTNL.  Holding the bond->lock also caused might_sleep issues for
> some drivers' ndo_vlan_* functions.  This patch removes the extra
> locking.
> 
> 	Problem reported by Michael Chan <mchan@broadcom.com>
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied.

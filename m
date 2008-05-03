From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] bonding: fix enslavement error unwinds
Date: Fri, 02 May 2008 17:52:22 -0700 (PDT)
Message-ID: <20080502.175222.220566217.davem@davemloft.net>
References: <12097757832778-git-send-email-fubar@us.ibm.com>
	<12097757842821-git-send-email-fubar@us.ibm.com>
	<12097757841898-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58060
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765303AbYECAwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 20:52:22 -0400
In-Reply-To: <12097757841898-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri,  2 May 2008 17:49:40 -0700

> 	For commit c2edacf80e155ef54ae4774379d461b60896bc2e, two steps
> were rearranged in the enslavement process: netdev_set_master is now
> before the call to dev_open to open the slave.

Please add the commit header line text to this SHA-ID reference.

> 	This patch updates the error cases and unwind process at the
> end of bond_enslave to match the new order.  Without this patch, it is
> possible for the enslavement to fail, but leave the slave with IFF_SLAVE
> set in its flags.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Otherwise:

Acked-by: David S. Miller <davem@davemloft.net>

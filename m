From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 6/6] bonding: disallow change of MAC if
 fail_over_mac enabled
Date: Fri, 07 Jun 2013 15:06:28 -0700 (PDT)
Message-ID: <20130607.150628.1095723147945965442.davem@davemloft.net>
References: <1370037451-29466-1-git-send-email-fubar@us.ibm.com>
	<1370037451-29466-7-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49079 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756072Ab3FGWG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 18:06:29 -0400
In-Reply-To: <1370037451-29466-7-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 31 May 2013 14:57:31 -0700

> 	Currently, if fail_over_mac is set to active, then attempts to
> change the MAC of the bond itself silently fail.  However, if fail_over_mac
> is set to follow, changes are permitted.
> 
> 	Permitting the bond's MAC to change with fail_over_mac=follow
> will disrupt the follow functionality, which normally controls the
> assignment of MAC address to the bond and its slaves, and can cause
> multiple ports to be assigned the same MAC address. which will interfere
> with the functioning of the device (where the device here is a
> virtualization-aware card for s390, qeth).
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied to net-next.

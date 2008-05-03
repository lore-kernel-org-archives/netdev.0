From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH REPOST 4/4] bonding: fix enslavement error unwinds
Date: Fri, 02 May 2008 18:07:21 -0700 (PDT)
Message-ID: <20080502.180721.97386451.davem@davemloft.net>
References: <12097757841898-git-send-email-fubar@us.ibm.com>
	<20080502.175222.220566217.davem@davemloft.net>
	<21092.1209776762@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35302
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761075AbYECBHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 21:07:21 -0400
In-Reply-To: <21092.1209776762@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 02 May 2008 18:06:02 -0700

> 
> 	As part of:
> 
> commit c2edacf80e155ef54ae4774379d461b60896bc2e
> Author: Jay Vosburgh <fubar@us.ibm.com>
> Date:   Mon Jul 9 10:42:47 2007 -0700
> 
>     bonding / ipv6: no addrconf for slaves separately from master
> 
> two steps were rearranged in the enslavement process: netdev_set_master
> is now before the call to dev_open to open the slave.
> 
> 	This patch updates the error cases and unwind process at the
> end of bond_enslave to match the new order.  Without this patch, it is
> possible for the enslavement to fail, but leave the slave with IFF_SLAVE
> set in its flags.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Thanks for fixing up the commit message:

Acked-by: David S. Miller <davem@davemloft.net>

From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bridge: show offload settings
Date: Fri, 15 Aug 2008 15:59:43 -0700
Message-ID: <10558.1218841183@death.nxdomain.ibm.com>
References: <20080815100259.12c8175a@extreme> <20080815.145118.198768799.davem@davemloft.net>
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:34729 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753452AbYHOW7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 18:59:47 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7FMxk6i006058
	for <netdev@vger.kernel.org>; Fri, 15 Aug 2008 18:59:46 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7FMxjN2177018
	for <netdev@vger.kernel.org>; Fri, 15 Aug 2008 16:59:45 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7FMxjpa031353
	for <netdev@vger.kernel.org>; Fri, 15 Aug 2008 16:59:45 -0600
In-reply-to: <20080815.145118.198768799.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: Stephen Hemminger <shemminger@vyatta.com>
>Date: Fri, 15 Aug 2008 10:02:59 -0700
>
>> Add more ethtool generic operations to dump the bridge offload
>> settings.
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
>Applied, thanks.

	I might be confused, but it looks like Stephen included the
wrong patch; it references "bridge" in the comments, but duplicates his
earlier patch for bonding:

Date: 	Fri, 15 Aug 2008 10:02:59 -0700
From: Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Subject: [PATCH] bridge: show offload settings
Organization: Vyatta

Add more ethtool generic operations to dump the bridge offload
settings.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/bonding/bond_main.c	2008-08-11 11:22:42.000000000 -0700
+++ b/drivers/net/bonding/bond_main.c	2008-08-11 11:26:07.000000000 -0700
@@ -4493,6 +4493,12 @@ static void bond_ethtool_get_drvinfo(str

 static const struct ethtool_ops bond_ethtool_ops = {
 	.get_drvinfo		= bond_ethtool_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+	.get_tx_csum		= ethtool_op_get_tx_csum,
+	.get_sg			= ethtool_op_get_sg,
+	.get_tso		= ethtool_op_get_tso,
+	.get_ufo		= ethtool_op_get_ufo,
+	.get_flags		= ethtool_op_get_flags,
 };

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: fix sparse warning
Date: Wed, 23 Feb 2011 14:29:03 -0800
Message-ID: <1116.1298500143@death>
References: <20110223094033.0c2268b4@nehalam>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:52574 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754196Ab1BWW3H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 17:29:07 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1NMAAtB013961
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 17:10:10 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1NMT6St208624
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 17:29:06 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1NMT5DN011495
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 19:29:06 -0300
In-reply-to: <20110223094033.0c2268b4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:

>Fix use of zero where NULL expected. And wrap long line.
>
>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


>--- a/drivers/net/bonding/bonding.h	2011-02-23 09:33:39.493248155 -0800
>+++ b/drivers/net/bonding/bonding.h	2011-02-23 09:33:48.825356637 -0800
>@@ -265,7 +265,8 @@ struct bonding {
>  *
>  * Caller must hold bond lock for read
>  */
>-static inline struct slave *bond_get_slave_by_dev(struct bonding *bond, struct net_device *slave_dev)
>+static inline struct slave *bond_get_slave_by_dev(struct bonding *bond,
>+						  struct net_device *slave_dev)
> {
> 	struct slave *slave = NULL;
> 	int i;
>@@ -276,7 +277,7 @@ static inline struct slave *bond_get_sla
> 		}
> 	}
>
>-	return 0;
>+	return NULL;
> }
>
> static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)

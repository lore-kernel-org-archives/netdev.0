From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next] bonding: make bond_resend_igmp_join_requests_delayed static
Date: Fri, 15 Oct 2010 16:15:31 -0700
Message-ID: <24262.1287184531@death>
References: <20101015140256.4192fd34@nehalam>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:48448 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674Ab0JOXPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 19:15:34 -0400
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o9FNDP9Z018206
	for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 17:13:25 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9FNFXRR128754
	for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 17:15:33 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9FNFX4A019155
	for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 17:15:33 -0600
In-reply-to: <20101015140256.4192fd34@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:


>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
>--- a/drivers/net/bonding/bond_main.c	2010-10-15 13:52:01.747192520 -0700
>+++ b/drivers/net/bonding/bond_main.c	2010-10-15 13:52:39.004286643 -0700
>@@ -914,7 +914,7 @@ static void bond_resend_igmp_join_reques
> 	read_unlock(&bond->lock);
> }
>
>-void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
>+static void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
> {
> 	struct bonding *bond = container_of(work, struct bonding,
> 							mcast_work.work);

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

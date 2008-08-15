From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: add more ethtool support
Date: Fri, 15 Aug 2008 15:58:53 -0700
Message-ID: <10549.1218841133@death.nxdomain.ibm.com>
References: <20080811113416.178e7446@extreme>
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:55015 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752941AbYHOW64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 18:58:56 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7FMwt6L027608
	for <netdev@vger.kernel.org>; Fri, 15 Aug 2008 18:58:55 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7FMwtVL184504
	for <netdev@vger.kernel.org>; Fri, 15 Aug 2008 16:58:55 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7FMwsne009907
	for <netdev@vger.kernel.org>; Fri, 15 Aug 2008 16:58:55 -0600
In-reply-to: <20080811113416.178e7446@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stephen Hemminger <stephen.hemminger@vyatta.com> wrote:

>This patch allows reporting the link, checksum, and feature settings
>of bonded device by using generic hooks.
>
>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
>--- a/drivers/net/bonding/bond_main.c	2008-08-11 11:22:42.000000000 -0700
>+++ b/drivers/net/bonding/bond_main.c	2008-08-11 11:26:07.000000000 -0700
>@@ -4493,6 +4493,12 @@ static void bond_ethtool_get_drvinfo(str
>
> static const struct ethtool_ops bond_ethtool_ops = {
> 	.get_drvinfo		= bond_ethtool_get_drvinfo,
>+	.get_link		= ethtool_op_get_link,
>+	.get_tx_csum		= ethtool_op_get_tx_csum,
>+	.get_sg			= ethtool_op_get_sg,
>+	.get_tso		= ethtool_op_get_tso,
>+	.get_ufo		= ethtool_op_get_ufo,
>+	.get_flags		= ethtool_op_get_flags,
> };
>
> /*

	Jeff, please apply.

Acked-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

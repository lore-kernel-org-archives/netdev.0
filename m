From: Kumar SANGHVI <kumar.sanghvi@stericsson.com>
Subject: Query on usage of Netlink
Date: Fri, 8 Oct 2010 14:21:28 +0530
Message-ID: <20101008085056.GA13091@bnru01.bnr.st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <srinidhi.kasagar@stericsson.com>, <linus.walleij@stericsson.com>,
	<kumar.sanghvi@stericsson.com>, <sudeep.divakaran@stericsson.com>,
	<gulshan.karmani@stericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:33020 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754079Ab0JHIvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 04:51:33 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 40C5D5A
	for <netdev@vger.kernel.org>; Fri,  8 Oct 2010 08:51:31 +0000 (GMT)
Received: from relay1.stm.gmessaging.net (unknown [10.230.100.17])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id E61471C9D
	for <netdev@vger.kernel.org>; Fri,  8 Oct 2010 08:51:30 +0000 (GMT)
Received: from exdcvycastm022.EQ1STM.local (alteon-source-exch [10.230.100.61])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(Client CN "exdcvycastm022", Issuer "exdcvycastm022" (not verified))
	by relay1.stm.gmessaging.net (Postfix) with ESMTPS id B6B1824C2F0
	for <netdev@vger.kernel.org>; Fri,  8 Oct 2010 10:51:25 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

We have a requirement where-in we want to communicate the status of
modem (whether modem is online or offline) from linux driver to
user-space components. So that user-space components stop sending data
to linux driver for communicating with modem, in case modem goes
offline.

We have decided to use the netlink mechanism to achieve this. We intend
to send an integer value, defined in enum, to user-space indicating the
current modem status.

For this, we want to know what Netlink message type should we use?
Should we use some existing Netlink type? Will there be any risk of
getting other messages (the ones not sent by our driver) if using
existing Netlink message type? For e.g. if we use the existing type
NETLINK_ROUTE then, user-space may un-necessary receive netlink notification
for route changes.

Or should we define a custom Netlink type in include/linux/netlink.h?

Thank you for suggestions.

Best regards,
Kumar.

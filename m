From: Roel Kluin <12o3l@tiscali.nl>
Subject: drivers/net/tokenring/smctr.c: logical-bitwise or confusion?
Date: Sun, 09 Mar 2008 22:43:43 +0100
Message-ID: <47D45A0F.1060102@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jschlst@samba.org, p_gortmaker@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out1.tiscali.nl ([195.241.79.176]:34585 "EHLO
	smtp-out1.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbYCIVoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2008 17:44:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/tokenring/smctr.c:3416

tsv->svv[0] = ((tx_fstatus & 0x0100 >> 6) || IBM_PASS_SOURCE_ADDR);

shouldn't this be a bit-wise or?
from drivers/net/tokenring/smctr.h:50:

#define      IBM_PASS_SOURCE_ADDR    0x01

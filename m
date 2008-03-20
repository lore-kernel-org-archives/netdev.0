From: Roel Kluin <12o3l@tiscali.nl>
Subject: drivers/net/niu.c: memcpy(dev->dev_addr, dev->perm_addr, dev->addr_len)?
Date: Thu, 20 Mar 2008 22:01:02 +0100
Message-ID: <47E2D08E.5050708@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out3.tiscali.nl ([195.241.79.178]:39763 "EHLO
	smtp-out3.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756424AbYCTVCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 17:02:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in drivers/net/niu.c, line 6406, 6286 and 7173:

memcpy(dev->dev_addr, dev->perm_addr, dev->addr_len);

I noticed that "

memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len)

occurs much more often (15x). could it be that the first two arguments
are swapped in niu.c?

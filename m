From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 0/5] skge: new version 1.6
Date: Tue, 06 Jun 2006 10:11:10 -0700
Message-ID: <20060606171110.592587000@zqx3.pdx.osdl.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:58834 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750899AbWFFRPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2006 13:15:03 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Go back to handling transmit completion via IRQ not NAPI. This works
better and is cleaner. Handle PHY via work queue, not tasklet.


--


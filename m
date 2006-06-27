From: Brent Cook <bcook@bpointsys.com>
Subject: [PATCH 0/3] mv643xx fixes
Date: Tue, 27 Jun 2006 09:51:54 -0500
Message-ID: <200606270951.54708.bcook@bpointsys.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from 70-253-197-251.ded.swbell.net ([70.253.197.251]:8213 "EHLO
	bpointsys.com") by vger.kernel.org with ESMTP id S1030193AbWF0Ovl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 10:51:41 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a series of fixes that for problems that we've found with the Marvell 
MV643xx Gigabit MAC.

 * Disable interrupts on all ports during initialization
 * Increment TX bytes statistics counter
 * Support BCM5461 PHY initialization

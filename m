From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: only use primary address for ARP
Date: Tue, 29 Nov 2011 18:33:33 -0500 (EST)
Message-ID: <20111129.183333.264311303683260906.davem@davemloft.net>
References: <20111124093715.GA25365@as68121.uab.ericsson.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: henrik.e.persson@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44509 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755941Ab1K2Xdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 18:33:40 -0500
In-Reply-To: <20111124093715.GA25365@as68121.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henrik Saavedra Persson <henrik.e.persson@ericsson.com>
Date: Thu, 24 Nov 2011 10:37:15 +0100

> Only use the primary address of the bond device
> for master_ip. This will prevent changing the ARP source
> address in Active-Backup mode whenever a secondry address
> is added to the bond device.
> 
> Signed-off-by: Henrik Saavedra Persson <henrik.e.persson@ericsson.com>

Bonding hackers, please review this.

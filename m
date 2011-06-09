From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5 net-next] cnic: Improve NETDEV_UP event handling
Date: Wed, 08 Jun 2011 23:53:21 -0700 (PDT)
Message-ID: <20110608.235321.1331847892255858928.davem@davemloft.net>
References: <1307597376-5379-2-git-send-email-mchan@broadcom.com>
	<1307597376-5379-3-git-send-email-mchan@broadcom.com>
	<1307597376-5379-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46830 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419Ab1FIGxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 02:53:23 -0400
In-Reply-To: <1307597376-5379-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 8 Jun 2011 22:29:35 -0700

> During NETDEV_UP, we use symbol_get() to get the net driver's cnic
> probe function.  This sometimes doesn't work if NETDEV_UP happens
> right after NETDEV_REGISTER and the net driver is still running module
> init code.  As a result, the cnic device may not be discovered.  We
> fix this by probing on all NETDEV events if the device's netif_running
> state is up.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.

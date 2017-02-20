From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ena: remove superfluous check in ena_remove()
Date: Mon, 20 Feb 2017 10:23:25 -0500 (EST)
Message-ID: <20170220.102325.989115726322379292.davem@davemloft.net>
References: <1487416781-3431-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeed@annapurnalabs.com, zorik@annapurnalabs.com,
        netdev@vger.kernel.org
To: LinoSanfilippo@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38338 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752148AbdBTPYl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 10:24:41 -0500
In-Reply-To: <1487416781-3431-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Sat, 18 Feb 2017 12:19:41 +0100

> The check in ena_remove() for the pci driver data not being NULL is not
> needed, since it is always set in the probe() function. Remove the
> superfluous check.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Applied.

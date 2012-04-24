From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: only register irq after setting up ports
Date: Tue, 24 Apr 2012 00:37:07 -0400 (EDT)
Message-ID: <20120424.003707.1304020185354100560.davem@davemloft.net>
References: <1335188789-6211-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35335 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421Ab2DXEhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 00:37:11 -0400
In-Reply-To: <1335188789-6211-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Mon, 23 Apr 2012 10:46:29 -0300

> If we receive an interrupt too early before we set up ports in the probe
> function, there won't be any port ready to handle it.
> 
> Only registering the irq after the ports are setup fixes the problem,
> and works fine without losing any interrupts.
> 
> This causes crashes in some situations:
 ...
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
> Cc: stable@vger.kernel.org

Applied, thanks for fixing this properly.

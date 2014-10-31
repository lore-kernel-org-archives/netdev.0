From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethernet: mvneta: Use PHY status standard
 message
Date: Fri, 31 Oct 2014 16:11:46 -0400 (EDT)
Message-ID: <20141031.161146.261120190123019342.davem@davemloft.net>
References: <1414771040-7789-1-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, nadavh@marvell.com,
	tawfik@marvell.com, alior@marvell.com, netdev@vger.kernel.org
To: ezequiel.garcia@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43202 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbaJaULs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 16:11:48 -0400
In-Reply-To: <1414771040-7789-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Date: Fri, 31 Oct 2014 12:57:20 -0300

> Use phy_print_status() to report a change in the PHY status.
> The current message is not verbose enough, so this commit improves
> it by using the generic status message.
> 
> After this change, the kernel reports PHY status down and up events as:
> 
> mvneta f1070000.ethernet eth0: Link is Down
> mvneta f1070000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
> 
> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>

Applied, thanks.

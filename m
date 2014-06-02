From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: of_mdio: use int type for address variable
Date: Mon, 02 Jun 2014 10:43:23 -0700 (PDT)
Message-ID: <20140602.104323.2040619784965255513.davem@davemloft.net>
References: <1401708766-5530-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, netdev@vger.kernel.org,
	sfr@canb.auug.org.au
To: zonque@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35197 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404AbaFBRnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 13:43:24 -0400
In-Reply-To: <1401708766-5530-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <zonque@gmail.com>
Date: Mon,  2 Jun 2014 13:32:45 +0200

> Use int rather than u32 to fix the following warning:
> 
> drivers/of/of_mdio.c:147 of_mdiobus_register() warn: unsigned 'addr' is
> never less than zero.
> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> Fixes: 8f8382888cba ("net: of_mdio: factor out code to parse a phy's 'reg' property")

Applied.

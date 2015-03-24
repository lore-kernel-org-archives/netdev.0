From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: Intialize link state to down before
 register_netdev
Date: Tue, 24 Mar 2015 15:41:07 -0400 (EDT)
Message-ID: <20150324.154107.1532418957897515351.davem@davemloft.net>
References: <OF515B2C92.39F94674-ON88257E12.00676FA3-88257E12.00679D6B@selinc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, netdev@vger.kernel.org
To: cliff_clark@selinc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39043 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459AbbCXTlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 15:41:09 -0400
In-Reply-To: <OF515B2C92.39F94674-ON88257E12.00676FA3-88257E12.00679D6B@selinc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: cliff_clark@selinc.com
Date: Tue, 24 Mar 2015 11:51:44 -0700

> ucc_geth was indicating link up after a port is administratively enabled 
> even
> when nothing is plugged in.  This causes user-space tools to see a 
> spurious link
> up the first time after boot.

Your commit message is still mis-formatted.  Use a plain ASCII editor
to create your commit message, rather than a graphical user interface.

> --- a/drivers/net/ethernet/freescale/ucc_geth.c
> +++ b/drivers/net/ethernet/freescale/ucc_geth.c
> @@ -3893,6 +3893,9 @@ static int ucc_geth_probe(struct platform_device* 
> ofdev)

Your email client corrupted your patch.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 14:12:17 -0700 (PDT)
Message-ID: <20071005.141217.41646184.davem@davemloft.net>
References: <20071005.031209.57156822.davem@davemloft.net>
	<20071005084036.52dc943c@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39140
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756537AbXJEVMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 17:12:21 -0400
In-Reply-To: <20071005084036.52dc943c@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 5 Oct 2007 08:40:36 -0700

> WARNING: braces {} are not necessary for single statement blocks
> #691: FILE: drivers/net/niu.c:603:
> +	if (lp->loopback_mode == LOOPBACK_PHY) {
> +		test_cfg_val |= ((ENET_TEST_MD_PAD_LOOPBACK <<
> +				  ENET_SERDES_TEST_MD_0_SHIFT) |
> +				 (ENET_TEST_MD_PAD_LOOPBACK <<
> +				  ENET_SERDES_TEST_MD_1_SHIFT) |
> +				 (ENET_TEST_MD_PAD_LOOPBACK <<
> +				  ENET_SERDES_TEST_MD_2_SHIFT) |
> +				 (ENET_TEST_MD_PAD_LOOPBACK <<
> +				  ENET_SERDES_TEST_MD_3_SHIFT));
> +	}

This is why I don't run checkpatch on my work.

This statement is a "single statement" but it's broken up
into multiple lines for readability, and it make perfect
sense to put braces around this basic block so it's easier
for humans to see what's going on.

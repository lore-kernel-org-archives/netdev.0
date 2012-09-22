From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3 V3] phy/micrel: Implement support for KSZ8021
Date: Sat, 22 Sep 2012 15:31:22 -0400 (EDT)
Message-ID: <20120922.153122.1337768859179326955.davem@davemloft.net>
References: <1348278110-11603-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.choi@micrel.com,
	nobuhiro.iwamatsu.yj@renesas.com
To: marex@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34667 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527Ab2IVTbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 15:31:24 -0400
In-Reply-To: <1348278110-11603-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Vasut <marex@denx.de>
Date: Sat, 22 Sep 2012 03:41:47 +0200

> +	.name		= "Micrel KSZ8021",
> +	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
> +				SUPPORTED_Asym_Pause),

You only fixed one of the two coding style problems I pointed out.

>From my original email:

====================
This is similarly not styled properly.

Besies being indented imporperly on the second line, the final "|"
character should be at the end of the first line, rather than
start the second line.
====================

Note "indented improperly on the second line"

Which is a clear reference to the first piece of
feedback I gave earlier in the same reply:

====================
This is not indented properly.  The goal is not to exclusively use
TAB characters to indent code until it sort-of looks fine.

Rather, the goal is to properly line up function arguments with
the first column after the openning parenthesis on the previous
line.  Using TAB and SPACE characters, as needed.
====================

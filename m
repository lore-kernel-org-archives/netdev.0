From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] phylib: Modify Vitesse RGMII skew settings
Date: Wed, 19 Oct 2011 16:00:09 -0400 (EDT)
Message-ID: <20111019.160009.1433033738937488070.davem@davemloft.net>
References: <1318516435-24314-1-git-send-email-afleming@freescale.com>
	<1318516435-24314-2-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59689 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753219Ab1JSUAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 16:00:13 -0400
In-Reply-To: <1318516435-24314-2-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Thu, 13 Oct 2011 09:33:55 -0500

> The Vitesse driver was using the RGMII_ID interface type to determine if
> skew was necessary.  However, we want to move away from using that
> interface type, as it's really a property of the board's PHY connection.
> However, some boards depend on it, so we want to support it, while
> allowing new boards to use the more flexible "fixups" approach.  To do
> this, we extract the code which adds skew into its own function, and
> call that function when RGMII_ID has been selected.
> 
> Another side-effect of this change is that if your PHY has skew set
> already, it doesn't clear it.  This way, the fixup code can modify the
> register without config_init then clearing it.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Applied.

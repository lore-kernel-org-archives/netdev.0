From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/9] net: phy: consolidate PHY reset
Date: Mon, 09 Dec 2013 20:39:48 -0500 (EST)
Message-ID: <20131209.203948.65965061063587576.davem@davemloft.net>
References: <1386363698-8407-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sebastian.hesselbarth@gmail.com,
	sergei.shtylyov@cogentembedded.com, afleming@gmail.com,
	kyle@moffetthome.net
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44914 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab3LJBju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 20:39:50 -0500
In-Reply-To: <1386363698-8407-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 6 Dec 2013 13:01:29 -0800

> This patchset consolidates the PHY reset through the MII BMCR
> register by using a central place were this is done.
> 
> This patchset resumes the work Kyle Moffett started here:
> https://lkml.org/lkml/2011/10/20/301
> 
> Note that at this point, drivers doing funky things after issuing
> a PHY reset using phy_init_hw() will still suffer from PHY state
> machine problems, this will be taken care of later on.

This looks fantastic, thanks for tackling this I know it isn't
easy.

Applied, thanks again!

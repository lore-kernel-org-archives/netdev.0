From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: phy: Allow EEE for all RGMII variants
Date: Fri, 15 May 2015 21:22:09 -0400 (EDT)
Message-ID: <20150515.212209.277936395883084581.davem@davemloft.net>
References: <1431732641-17683-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@roeck-us.net, peppe.cavallaro@st.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934479AbbEPBWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 21:22:13 -0400
In-Reply-To: <1431732641-17683-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 15 May 2015 16:30:41 -0700

> RGMII interfaces come in multiple flavors: RGMII with transmit or
> receive internal delay, no delays at all, or delays in both direction.
> 
> This change extends the initial check for PHY_INTERFACE_MODE_RGMII to
> cover all of these variants since EEE should be allowed for any of these
> modes, since it is a property of the RGMII, hence Gigabit PHY capability
> more than the RGMII electrical interface and its delays.
> 
> Fixes: a59a4d192166 ("phy: add the EEE support and the way to access to the MMD registers")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

This is not the first time I've seen this bug.

A helper like phydev_is_rgmii() is probably long overdue.

> David this change dates back to 3.6, however the comment update will depend on
> a9f6309585cbefa4a7f08c9017ca482c3222323a ("net: phy: allow phy_init_eee() to
> work with internal PHYs") to be included, which is only 3.18, nobody but me
> really complained about that so I guess 3.18+ is reasonable.

Ok, applied and queued up for -stable, thanks.

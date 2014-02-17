From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] net: phy: soft reset rework for 10G
 PHYs
Date: Mon, 17 Feb 2014 16:41:27 -0500 (EST)
Message-ID: <20140217.164127.581023270379747215.davem@davemloft.net>
References: <1392672844-1767-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shaohui.Xie@freescale.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51521 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754217AbaBQVl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 16:41:29 -0500
In-Reply-To: <1392672844-1767-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 17 Feb 2014 13:34:01 -0800

> Hi David,
> 
> As reported by Shaohui, 10G PHYs may have a slightly more complex reset
> sequence for which a BMCR_RESET software reset might not suffice. This
> patchset offers a solution for those by allowing them to implement their
> own soft_reset() callback. Finally there is an update to the PHY library
> Documentation to cover for the newly added callbacks of the PHY driver
> structure.
> 
> Thanks!
> 
> Changes in v2:
> - fixed callback testing
> - fixed typo in Documentation

Much better, series applied, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: marvell: add link partner advertised modes
Date: Fri, 25 Sep 2015 12:24:03 -0700 (PDT)
Message-ID: <20150925.122403.23348450986009139.davem@davemloft.net>
References: <E1Zet89-0003P6-Ee@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: rmk+kernel@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932918AbbIYTYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 15:24:07 -0400
In-Reply-To: <E1Zet89-0003P6-Ee@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@arm.linux.org.uk>
Date: Thu, 24 Sep 2015 00:07:17 +0100

> Read the standard link partner advertisment registers and store it in
> phydev->lp_advertising, so ethtool can report this information to
> userspace via ethtool.  Zero it as per genphy if autonegotiation is
> disabled.  Tested with a Marvell 88E1512 PHY.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Applied, thanks.

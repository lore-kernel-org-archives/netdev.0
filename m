From: Kosta Zertsekel <konszert@marvell.com>
Subject: RE: [RFC PATCH] net: phy: remove flags argument from
 phy_{attach,connect,connect_direct}
Date: Sun, 13 Jan 2013 10:54:12 +0200
Message-ID: <BC373419EB4337418B2B595BAEDC155F015896370201@IL-MB01.marvell.com>
References: <1357903907-16049-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"afleming@gmail.com" <afleming@gmail.com>
To: Florian Fainelli <florian@openwrt.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from galiil.marvell.com ([199.203.130.254]:40317 "EHLO
	galiil.marvell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743Ab3AMIyR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 03:54:17 -0500
In-Reply-To: <1357903907-16049-1-git-send-email-florian@openwrt.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The flags argument of the phy_{attach,connect,connect_direct} functions is used to assign a struct phy_device dev_flags with the value passed.
> All callers but the tg3 driver pass the flag 0, which results in the underlying PHY drivers in drivers/net/phy/ not being able to actually use any
> of the flags they would check in dev_flags. This patch gets rid of the flags argument, and passes phydev->dev_flags to the internal PHY library call
> phy_attach_direct() such that drivers which actually modify a phy device dev_flags get the value preserved for use by the underly phy driver.

Acked by konszert@marvell.com.

It seems this patch should be reposted on linux-kernel@vger.kernel.org list for wider approval, isn't it?
Anyway, I think it is prudent to abandon my narrow patch that fixed only phy_attach() in mv643xx network driver.

--- KostaZ

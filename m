From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: broadcom: rehook BCM54612E specific init
Date: Wed, 01 Feb 2017 14:20:32 -0500 (EST)
Message-ID: <20170201.142032.218330612110187827.davem@davemloft.net>
References: <20170131215454.7932-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Cc: f.fainelli@gmail.com, xow@google.com, joel@jms.id.au,
        jon.mason@broadcom.com, jaedon.shin@gmail.com,
        netdev@vger.kernel.org, rafal@milecki.pl
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45278 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751068AbdBATUe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 14:20:34 -0500
In-Reply-To: <20170131215454.7932-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafa©© Mi©©ecki <zajec5@gmail.com>
Date: Tue, 31 Jan 2017 22:54:54 +0100

> From: Rafa©© Mi©©ecki <rafal@milecki.pl>
> 
> This extra BCM54612E code in PHY driver isn't really aneg specific. Even
> without it aneg works OK but the problem is no packets pass through PHY.
> 
> Moreover putting this code inside config_aneg callback didn't allow
> resuming PHY correctly. When driver called phy_stop and phy_start it was
> putting PHY machine into RESUMING state. After that machine was
> switching into AN and NOLINK without ever calling phy_start_aneg. This
> prevented this extra setup from being called and PHY didn't work.
> 
> This change has been verified to fix network on BCM47186B0 SoC device
> with BCM54612E.
> 
> Signed-off-by: Rafa©© Mi©©ecki <rafal@milecki.pl>

Applied to net-next, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: smsc: Re-enable EDPD mode for LAN87xx
Date: Thu, 15 Nov 2012 17:49:10 -0500 (EST)
Message-ID: <20121115.174910.1186195664618812261.davem@davemloft.net>
References: <1353006057-7593-1-git-send-email-patrick.trantham@fuel7.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
	otavio@ossystems.com.br, marex@denx.de, chohnstaedt@innominate.com,
	jkosina@suse.cz
To: patrick.trantham@fuel7.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49143 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729Ab2KOWtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 17:49:12 -0500
In-Reply-To: <1353006057-7593-1-git-send-email-patrick.trantham@fuel7.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Trantham <patrick.trantham@fuel7.com>
Date: Thu, 15 Nov 2012 13:00:57 -0600

> This patch re-enables Energy Detect Power Down (EDPD) mode for the
> LAN8710/LAN8720.  EDPD mode was disabled in a previous commit,
> (b629820d18fa65cc598390e4b9712fd5f83ee693), because it was causing the
> PHY to not be able to detect a link when cold started without a cable
> connected.
> 
> The LAN8710/LAN8720 requires a minimum of 2 link pulses within 64ms of
> each other in order to set the ENERGYON bit and exit EDPD mode.  If a
> link partner does send the pulses within this interval, the PHY will
> remained powered down.
> 
> This workaround will manually toggle the PHY on/off upon calls to
> read_status in order to generate link test pulses if the link is down.
> If a link partner is present, it will respond to the pulses, which will
> cause the ENERGYON bit to be set and will cause the EDPD mode to be
> exited.
> 
> Signed-off-by: Patrick Trantham <patrick.trantham@fuel7.com>

Applied to net-next, thanks.

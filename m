From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: phy: export phy_suspend and phy_resume
Date: Tue, 08 Jul 2014 20:37:34 -0700 (PDT)
Message-ID: <20140708.203734.373515318594628840.davem@davemloft.net>
References: <1404841116-8274-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vbridgers2013@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56164 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbaGIDhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 23:37:37 -0400
In-Reply-To: <1404841116-8274-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue,  8 Jul 2014 10:38:36 -0700

> phy_suspend and phy_resume are two commonly used helper functions that
> need to be exported for Ethernet drivers to be built as modules
> 
> Fixes: 40755a0fce17 ("net: systemport: add suspend and resume support")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

First of all, the commit in question went into 'net' not 'net-next'.

Second of all, I reverted it.

So this patch is not appropriate unless/until that commit gets
re-added, and it's not targetted at the proper tree anyways.

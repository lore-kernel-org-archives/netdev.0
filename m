From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bcmgenet: properly disable password matching
Date: Thu, 05 Mar 2015 21:16:19 -0500 (EST)
Message-ID: <20150305.211619.2253898945917128435.davem@davemloft.net>
References: <1425498183-28832-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37937 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbbCFCQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 21:16:20 -0500
In-Reply-To: <1425498183-28832-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed,  4 Mar 2015 11:43:03 -0800

> bcmgenet_set_wol() correctly sets MPD_PW_EN when a password is specified
> to match magic packets against, however, when we switch from a
> password-matching to a matching without password we would leave this bit
> turned on, and GENET would only match magic packets with passwords.
> 
> This can be reproduced using the following sequence:
> 
> ethtool -s eth0 wol g
> ethtool -s eth0 wol s sopass 00:11:22:33:44:55
> ethtool -s eth0 wol g
> 
> The simple fix is to clear the MPD_PWD_EN bit when WAKE_MAGICSECURE is
> not set.
> 
> Fixes: c51de7f3976b ("net: bcmgenet: add Wake-on-LAN support code")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: systemport: fix bcm_sysport_insert_tsb()
Date: Sat, 04 Oct 2014 20:33:31 -0400 (EDT)
Message-ID: <20141004.203331.59914772416180085.davem@davemloft.net>
References: <1412268196-16086-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44161 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaJEAdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 20:33:33 -0400
In-Reply-To: <1412268196-16086-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu,  2 Oct 2014 09:43:16 -0700

> Similar to commit bc23333ba11fb7f959b7e87e121122f5a0fbbca8 ("net:
> bcmgenet: fix bcmgenet_put_tx_csum()"), we need to return the skb
> pointer in case we had to reallocate the SKB headroom.
> 
> Fixes: 80105befdb4b8 ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable, thanks Florian.

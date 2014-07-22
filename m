From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: only update UMAC_CMD if
 something changed
Date: Mon, 21 Jul 2014 19:49:29 -0700 (PDT)
Message-ID: <20140721.194929.2045969592618032422.davem@davemloft.net>
References: <1405989759-1453-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40337 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852AbaGVCtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 22:49:33 -0400
In-Reply-To: <1405989759-1453-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 21 Jul 2014 17:42:39 -0700

> The link adjustment callback can be called as frequently as desired
> by the PHY library, as such, let's avoid doing a Read/Modify/Write
> sequence if nothing changed, since these register accesses can be
> expensive.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bcmgenet: fix RGMII_MODE_EN bit
Date: Sun, 13 Jul 2014 22:55:50 -0700 (PDT)
Message-ID: <20140713.225550.840518028769925450.davem@davemloft.net>
References: <1405122915-7756-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573AbaGNFzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 01:55:51 -0400
In-Reply-To: <1405122915-7756-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 11 Jul 2014 16:55:15 -0700

> RGMII_MODE_EN bit was defined to 0, while it is actually 6. It was not
> much of a problem on older designs where this was a no-op, and the RGMII
> data-path would always be enabled, but newer GENET controllers need to
> explicitely enable their RGMII data-pad using this bit.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thank you.

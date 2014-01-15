From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bgmac: propagate error codes in bgmac_probe()
Date: Tue, 14 Jan 2014 18:18:46 -0800 (PST)
Message-ID: <20140114.181846.387733651477301371.davem@davemloft.net>
References: <1389582355-27514-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zajec5@gmail.com, hauke@hauke-m.de,
	nlhintz@hotmail.com, sd@queasysnail.net, bhutchings@solarflare.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbaAOCSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 21:18:47 -0500
In-Reply-To: <1389582355-27514-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sun, 12 Jan 2014 19:05:55 -0800

> bgmac_mii_register() and register_netdev() both return appropriate error
> codes for the failures they would encounter, propagate this error code
> instead of overriding the value with -ENOTSUPP which is not the correct
> error code to return.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: bcmgenet: Remove checks on clock
 handles
Date: Sun, 26 Jul 2015 17:22:41 -0700 (PDT)
Message-ID: <20150726.172241.1747790153775031816.davem@davemloft.net>
References: <1437611303-29011-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37025 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755144AbbG0AWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 20:22:42 -0400
In-Reply-To: <1437611303-29011-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 22 Jul 2015 17:28:23 -0700

> Instead of multiplying the number of checks for IS_ERR(priv->clk),
> simply NULLify the 'struct clk' pointer which is something the Linux
> common clock framework perfectly deals with and does early return for
> each and every single clk_* API functions.
> 
> Having every single function check for !IS_ERR(priv->clk) is both
> redundant and error prone, as it turns out, we were doing it for the
> main GENET clock: priv->clk, but not for the Wake-on-LAN or EEE clock,
> so let's just be consistent here.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v2:
> 
> - remove all IS_ERR() checks as described, there were two missing in v1

Ahh, here it is :-)

Applied, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] of_mdio: kill useless variable in of_mdiobus_register()
Date: Tue, 01 Mar 2016 17:42:00 -0500 (EST)
Message-ID: <20160301.174200.926566152360746618.davem@davemloft.net>
References: <76681790.JernGlLJsj@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, frowand.list@gmail.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42883 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbcCAWmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 17:42:03 -0500
In-Reply-To: <76681790.JernGlLJsj@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 28 Feb 2016 21:56:34 +0300

> of_mdiobus_register()  declares the 'paddr' variable to hold the result of
> the of_get_property()  but only uses it once after that while the function
> can be called directly from the *if* statement. Remove that variable and
> switch to calling of_find_property() instead since  we don't care about
> the "reg" property's value anyway...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
> The patch is against DaveM's 'net-next.git' repo.

Applied.

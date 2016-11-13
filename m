From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: marvell: optimize logic for page changing
 during init
Date: Sun, 13 Nov 2016 12:05:32 -0500 (EST)
Message-ID: <20161113.120532.627984410317749893.davem@davemloft.net>
References: <20161110140301.13381-1-uwe@kleine-koenig.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: uwe@kleine-koenig.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43918 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934472AbcKMRFe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 12:05:34 -0500
In-Reply-To: <20161110140301.13381-1-uwe@kleine-koenig.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Uwe Kleine-König <uwe@kleine-koenig.org>
Date: Thu, 10 Nov 2016 15:03:01 +0100

> Instead of remembering if the page was changed, just compare the current
> page to the saved one. This is easier and has the advantage to save a
> register write if the page was already restored.
> 
> Signed-off-by: Uwe Kleine-König <uwe@kleine-koenig.org>

Applied to net-next, thanks.

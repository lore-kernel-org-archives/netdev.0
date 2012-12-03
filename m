From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] bnx2x: recognize fan failure
Date: Mon, 03 Dec 2012 13:47:42 -0500 (EST)
Message-ID: <20121203.134742.1564114308967610212.davem@davemloft.net>
References: <1354528609-17486-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com,
	yaniv.rosner@broadcom.com, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39332 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874Ab2LCSro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 13:47:44 -0500
In-Reply-To: <1354528609-17486-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Mon, 3 Dec 2012 11:56:49 +0200

> From: Yaniv Rosner <yaniv.rosner@broadcom.com>
> 
> If fan failure is detected, MCP prevents PCI I/O registers from being
> mapped to the bar, causing a fatal error as driver is unaware.
> 
> This patch recognizes such an event occurred and gracefully terminates
> the probe process.
> 
> Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
> Hi Dave,
> 
> This patch prevents a fatal error on newer bnx2x boards.
> 
> Please consider applying it to 'net'.

Too late, I've applied it to net-next.  I'm not asking Linus to hold back
an already delayed released for such a rarely triggering issue such as this
one.

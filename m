From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: cpsw: ignore VLAN ID 1
Date: Tue, 06 Jan 2015 16:59:11 -0500 (EST)
Message-ID: <20150106.165911.604916635790072318.davem@davemloft.net>
References: <1420566212-30081-1-git-send-email-balbi@ti.com>
	<20150106.141323.2091288413667564444.davem@davemloft.net>
	<20150106203119.GC32308@saruman>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	stable@vger.kernel.org, mugunthanvnm@ti.com
To: balbi@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56003 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755366AbbAFV7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 16:59:13 -0500
In-Reply-To: <20150106203119.GC32308@saruman>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felipe Balbi <balbi@ti.com>
Date: Tue, 6 Jan 2015 14:31:19 -0600

> What you're saying here is that you prefer to drop a feature that works
> for all other 1023 IDs because 1 ID is quirky. Sounds like overkill
> to me.

The other option is to software fallback only for VLAN 1.

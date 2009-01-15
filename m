From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] korina: fix usage of driver_data
Date: Wed, 14 Jan 2009 21:47:14 -0800 (PST)
Message-ID: <20090114.214714.214443882.davem@davemloft.net>
References: <20090112.215202.194850308.davem@davemloft.net>
	<1231955241-6440-1-git-send-email-n0-1@freewrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, florian@openwrt.org, jeff@garzik.org
To: n0-1@freewrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53780
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750874AbZAOFrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:47:13 -0500
In-Reply-To: <1231955241-6440-1-git-send-email-n0-1@freewrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <n0-1@freewrt.org>
Date: Wed, 14 Jan 2009 18:47:21 +0100

> Using platform_set_drvdata() here makes no sense, since the driver_data
> field has already been filled with valuable data (i.e. the MAC address).
> Also having driver_data point to the net_device is rather pointless
> since struct korina_device contains an apropriate field for it.
> 
> Signed-off-by: Phil Sutter <n0-1@freewrt.org>

Applied.

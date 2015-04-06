From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mvneta: dont call mvneta_adjust_link() manually
Date: Mon, 06 Apr 2015 16:36:29 -0400 (EDT)
Message-ID: <20150406.163629.812776722882819334.davem@davemloft.net>
References: <551C1B81.1040706@list.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	f.fainelli@gmail.com, linux-kernel@vger.kernel.org,
	stsp@users.sourceforge.net
To: stsp@list.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48280 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbbDFUgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 16:36:32 -0400
In-Reply-To: <551C1B81.1040706@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stas Sergeev <stsp@list.ru>
Date: Wed, 01 Apr 2015 19:23:29 +0300

> 
> mvneta_adjust_link() is a callback for of_phy_connect() and should
> not be called directly. The result of calling it directly is as below:
> ---
>  mvneta f1030000.ethernet eth1: Link is Up - Unsupported (update p
> hy.c)/Half - flow control off
> ---
> 
> This is because initially the struct phy_device is created with
> invalid parameters. phylib calls adjust_link() only when the parameters
> are validated, but calling it by hands may happen too early.
> 
> CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> CC: netdev@vger.kernel.org
> CC: linux-kernel@vger.kernel.org
> CC: Florian Fainelli <f.fainelli@gmail.com>
> 
> Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>

Applied, thanks.

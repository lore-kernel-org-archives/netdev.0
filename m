From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove unnecessary semicolon in
 netdev_alloc_pcpu_stats()
Date: Sun, 06 Dec 2015 22:32:48 -0500 (EST)
Message-ID: <20151206.223248.609122745261081525.davem@davemloft.net>
References: <1449320291-7727-1-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaloz@openwrt.org, pablo@netfilter.org
To: nbd@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755132AbbLGDcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 22:32:50 -0500
In-Reply-To: <1449320291-7727-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Fietkau <nbd@openwrt.org>
Date: Sat,  5 Dec 2015 13:58:11 +0100

> This semicolon causes a build error if the function call is wrapped in
> parentheses.
> 
> Fixes: aabc92bbe3cf ("net: add __netdev_alloc_pcpu_stats() to indicate gfp flags")
> Reported-by: Imre Kaloz <kaloz@openwrt.org>
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>

Good catch, applied, thank you.

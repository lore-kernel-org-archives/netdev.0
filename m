From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH] ksz884x: fix Endian
Date: Wed, 11 Jul 2012 01:31:44 -0700 (PDT)
Message-ID: <20120711.013144.561273373052992836.davem@davemloft.net>
References: <1341903366-15217-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tristram.Ha@micrel.com,
	bhutchings@solarflare.com, joe@perches.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45001 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755982Ab2GKIbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 04:31:45 -0400
In-Reply-To: <1341903366-15217-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Tue, 10 Jul 2012 14:56:06 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> ETH_P_IP is host Endian, skb->protocol is big Endian, when
> compare them, Using htons on skb->protocol is wrong.
> 
> And fix two code style issues: indentation and remove
> unnecessary parentheses.
> 
> CC: Tristram Ha <Tristram.Ha@micrel.com>
> CC: Ben Hutchings <bhutchings@solarflare.com>
> CC: Joe Perches <joe@perches.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] mld, igmp: Fix reserved tailroom calculation
Date: Thu, 03 Mar 2016 15:42:02 -0500 (EST)
Message-ID: <20160303.154202.520745115368181404.davem@davemloft.net>
References: <56D48DCE.3090705@stressinduktion.org>
	<1456787013-3277-1-git-send-email-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	eric.dumazet@gmail.com, hannes@stressinduktion.org,
	yoshfuji@linux-ipv6.org
To: bpoirier@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47158 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994AbcCCUmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 15:42:05 -0500
In-Reply-To: <1456787013-3277-1-git-send-email-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>
Date: Mon, 29 Feb 2016 15:03:33 -0800

> The current reserved_tailroom calculation fails to take hlen and tlen into
> account.
 ...
> Fixes: 4c672e4b ("ipv6: mld: fix add_grhead skb_over_panic for devs with large MTUs")
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>

Applied and queued up for -stable, thanks.

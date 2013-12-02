From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] xen-netback: fix fragment detection in checksum
 setup
Date: Mon, 02 Dec 2013 17:25:58 -0500 (EST)
Message-ID: <20131202.172558.955837311772996882.davem@davemloft.net>
References: <1386005715-27566-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	zoltan.kiss@citrix.com, wei.liu2@citrix.com,
	ian.campbell@citrix.com, david.vrabel@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55033 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752294Ab3LBWZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 17:25:59 -0500
In-Reply-To: <1386005715-27566-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Mon, 2 Dec 2013 17:35:15 +0000

> The code to detect fragments in checksum_setup() was missing for IPv4 and
> too eager for IPv6. (It transpires that Windows seems to send IPv6 packets
> with a fragment header even if they are not a fragment - i.e. offset is zero,
> and M bit is not set).
> This patch also incorporates a fix to callers of maybe_pull_tail() where
> skb->network_header was being erroneously added to the length argument.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> cc: David Miller <davem@davemloft.net>

This addresses my concerned, Ian and Wei please review.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Implement fast csum_partial for x86_64
Date: Mon, 04 Jan 2016 22:01:08 -0500 (EST)
Message-ID: <20160104.220108.58746007572013351.davem@davemloft.net>
References: <1451863347-1832521-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748AbcAEDBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 22:01:10 -0500
In-Reply-To: <1451863347-1832521-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Sun, 3 Jan 2016 15:22:27 -0800

> Implement assembly routine for csum_partial for 64 bit x86. This
> primarily speeds up checksum calculation for smaller lengths such as
> those that are present when doing skb_postpull_rcsum when getting
> CHECKSUM_COMPLETE from device or after CHECKSUM_UNNECESSARY
> conversion.
> 
> This implementation is similar to csum_partial implemented in
> checksum_32.S, however since we are dealing with 8 bytes at a time
> there are more cases for alignment and small lengths-- for those we
> employ jump tables.

Looks great, but probably has to go through the x86 maintainers
as Eric suggested.

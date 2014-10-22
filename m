From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tso: fix unaligned access to crafted TCP header
 in helper API
Date: Wed, 22 Oct 2014 12:53:08 -0400 (EDT)
Message-ID: <20141022.125308.822219038497859438.davem@davemloft.net>
References: <1413900365-12289-1-git-send-email-karl.beldan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, karl.beldan@rivierawaves.com,
	ezequiel.garcia@free-electrons.com
To: karl.beldan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541AbaJVQxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 12:53:10 -0400
In-Reply-To: <1413900365-12289-1-git-send-email-karl.beldan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karl Beldan <karl.beldan@gmail.com>
Date: Tue, 21 Oct 2014 16:06:05 +0200

> From: Karl Beldan <karl.beldan@rivierawaves.com>
> 
> The crafted header start address is from a driver supplied buffer, which
> one can reasonably expect to be aligned on a 4-bytes boundary.
> However ATM the TSO helper API is only used by ethernet drivers and
> the tcp header will then be aligned to a 2-bytes only boundary from the
> header start address.
> 
> Signed-off-by: Karl Beldan <karl.beldan@rivierawaves.com>

Applied, thank you.

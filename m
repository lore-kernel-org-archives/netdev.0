From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/6] net: Add helper for padding short Ethernet
 frames
Date: Mon, 08 Dec 2014 20:48:05 -0500 (EST)
Message-ID: <20141208.204805.781096468327619049.davem@davemloft.net>
References: <20141203161440.9223.39633.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755404AbaLIBsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 20:48:07 -0500
In-Reply-To: <20141203161440.9223.39633.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 03 Dec 2014 08:17:26 -0800

> This patch series adds a pair of helpers to pad short Ethernet frames.  The
> general idea is to clean up a number of code paths that were all writing
> their own versions of the same or similar function.
> 
> An added advantage is that this will help to discourage introducing new
> bugs as in at least one case I found the skb->len had been updated, but the
> tail pointer update was overlooked.
> 
> v2: Added skb_put_padto for cases where length is not ETH_ZLEN
>     Updated intel drivers and emulex driver to use skb_put_padto
>     Updated eth_skb_pad to use skb_put_padto

Series applied, thanks Alex.

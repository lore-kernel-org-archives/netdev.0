From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: convert mvneta to build_skb()
Date: Thu, 04 Jul 2013 14:31:03 -0700 (PDT)
Message-ID: <20130704.143103.1546241224422474244.davem@davemloft.net>
References: <20130704173552.GA23370@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, edumazet@google.com
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50886 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756878Ab3GDVbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 17:31:04 -0400
In-Reply-To: <20130704173552.GA23370@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Thu, 4 Jul 2013 19:35:52 +0200

> From 0180a5e651dd771de18bf2c031ecfe7bb4c88d3e Mon Sep 17 00:00:00 2001
> From: Willy Tarreau <w@1wt.eu>
> Date: Sat, 15 Jun 2013 23:25:15 +0200
> Subject: [PATCH] net: convert mvneta to build_skb()
> 
> We store the frag_size in the mvneta_port struct. In practice we'd need
> a single bit to know how to free the data, but since we need the size to
> call build_skb() anyway, let's store the full size.
> 
> With this patch, I observed a reproducible 2% performance improvement on
> HTTP-based benchmarks.
> 
> Signed-off-by: Willy Tarreau <w@1wt.eu>

The net-next tree is closed now that the merge window is open, therefore
submissions such as this are not appropriate at this time.

Please resubmit this when net-next opens again, an event which I will
clearly announce here on netdev.

Thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Thu, 15 Jan 2009 15:35:29 -0800 (PST)
Message-ID: <20090115.153529.134674284.davem@davemloft.net>
References: <20090115230331.GB1123@1wt.eu>
	<20090115231934.GA8328@gondor.apana.org.au>
	<20090115233220.GD1123@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jarkao2@gmail.com, zbr@ioremap.net,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58138
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S935389AbZAOXf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 18:35:28 -0500
In-Reply-To: <20090115233220.GD1123@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Fri, 16 Jan 2009 00:32:20 +0100

> Good catch Herbert, it's working fine now. The performance I get
> (30.6 MB/s) is between the original splice version (24.1) and the
> recently optimized one (35.7). That's not that bad considering
> we're copying the data.

Willy, see how much my skb clone removal in the patch I just
posted helps, if at all.

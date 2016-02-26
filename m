From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 3/3] net: convert tc_u32 to use the intermediate
 representation
Date: Fri, 26 Feb 2016 12:38:25 -0500 (EST)
Message-ID: <20160226.123825.1864319539835207932.davem@davemloft.net>
References: <20160226142402.GB2523@salvia>
	<56D066D7.2090708@gmail.com>
	<20160226160222.GA4499@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us,
	horms@verge.net.au
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754731AbcBZRi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 12:38:27 -0500
In-Reply-To: <20160226160222.GA4499@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 26 Feb 2016 17:02:22 +0100

> Just because you want to early microoptimize this thing by saving a
> little of extra code that runs from the control plane path.

I don't think that's what he is doing at all.

We have classes of classifier etc. offloads that need IR, and we have
those that don't.

There is nothing wrong with making this distinction and making our
design based upon that observation.

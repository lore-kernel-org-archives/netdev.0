From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix saving TX flow hash in sock for outgoing
 connections
Date: Wed, 22 Oct 2014 16:14:02 -0400 (EDT)
Message-ID: <20141022.161402.119032019463935567.davem@davemloft.net>
References: <1413999542.9031.13.camel@edumazet-glaptop2.roam.corp.google.com>
	<CF9D1877D81D214CB0CA0669EFAE020C68CA2FAA@CMEXMB1.ad.emulex.com>
	<1414004996.9031.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Sathya.Perla@Emulex.Com, netdev@vger.kernel.org,
	therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32955 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932328AbaJVUOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 16:14:03 -0400
In-Reply-To: <1414004996.9031.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 22 Oct 2014 12:09:56 -0700

> On Wed, 2014-10-22 at 18:35 +0000, Sathya Perla wrote:
>> Agree. Are you suggesting that drivers should automatically
>> register an XPS configuration? I thought it was upto the user
>> to enable it...
> 
> Yep, search for netif_set_xps_queue()
> 
> (commit 537c00de1c9ba9876b9)
> 
> Look at commit d03a68f8217ea0349 for an example of how it can be done,
> if user do not override this later.

Very few people know about this :-/

I only see 4 drivers adjusted to do this, it would be nice if this
was more widespread.

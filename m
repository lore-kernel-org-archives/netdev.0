From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 6lowpan: Remove unused pointer in
 lowpan_header_create()
Date: Mon, 10 Feb 2014 12:25:06 -0800 (PST)
Message-ID: <20140210.122506.1886597933081358012.davem@davemloft.net>
References: <20140207225838.18ad2ffb@spike>
	<20140209.183829.1382019488417715676.davem@davemloft.net>
	<20140210174056.GB12594@omega>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cengelma@gmx.at, netdev@vger.kernel.org,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	jukka.rissanen@linux.intel.com
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753873AbaBJUZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 15:25:10 -0500
In-Reply-To: <20140210174056.GB12594@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Mon, 10 Feb 2014 18:40:58 +0100

> I need the hdr pointer for my upcomming patches. Nevertheless it
> should be removed... it's not used anymore.
> 
> I am wondering why this patch was accepted, it's not a bug fix. Is
> net-next open again?

Unused variables make code difficult to audit for bugs and similar.

Sometimes I apply patches like these for net, net-next is not open
yet.

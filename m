From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lmc: Read outside array bounds
Date: Thu, 13 Aug 2009 16:27:04 -0700 (PDT)
Message-ID: <20090813.162704.229609927.davem@davemloft.net>
References: <4A7C401B.7090301@gmail.com>
	<20090809.212725.218498673.davem@davemloft.net>
	<4A8004B0.5000504@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56535
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753226AbZHMX0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 19:26:53 -0400
In-Reply-To: <4A8004B0.5000504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Mon, 10 Aug 2009 13:29:52 +0200

> If dev_alloc_skb() fails on the first iteration of the allocation loop,
> then we end up writing before the start of the array.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied to net-next-2.6

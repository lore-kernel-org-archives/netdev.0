From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: vlsi_ir: use %*ph specifier
Date: Sun, 07 Sep 2014 16:09:40 -0700 (PDT)
Message-ID: <20140907.160940.1917757437177026148.davem@davemloft.net>
References: <1409927840-28791-1-git-send-email-andriy.shevchenko@linux.intel.com>
	<5409F104.5040705@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andriy.shevchenko@linux.intel.com, samuel@sortiz.org,
	netdev@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56475 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752096AbaIGXJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 19:09:41 -0400
In-Reply-To: <5409F104.5040705@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 05 Sep 2014 21:21:08 +0400

> On 09/05/2014 06:37 PM, Andy Shevchenko wrote:
> 
>> + seq_printf(seq, " data: %*ph\n", j > 20 ? 20 : j,
> 
>    Why not min(j, 20)?

Agreed.

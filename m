From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: GRO support
Date: Mon, 03 May 2010 23:27:14 -0700 (PDT)
Message-ID: <20100503.232714.43422983.davem@davemloft.net>
References: <alpine.DEB.1.00.1005032203520.11991@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aabdulla@nvidia.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46288
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754655Ab0EDG1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 02:27:08 -0400
In-Reply-To: <alpine.DEB.1.00.1005032203520.11991@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 3 May 2010 22:08:45 -0700 (PDT)

> Add GRO support to forcedeth.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, nice work Tom.

I think it's really time to kill the NAPI ifdef crap from this driver.
Something marked "experimental" that people have been actively using
and distributions have been turning on for years isn't experimental
any more.

Actually this goes back to 2006 even.

In fact, I'm just going to kill it right now in net-next-2.6

Thanks again Tom!


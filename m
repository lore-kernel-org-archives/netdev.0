From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 2/2] shrink size of scatterlist on common i386/x86-64
Date: Thu, 05 Jul 2007 16:43:08 -0700 (PDT)
Message-ID: <20070705.164308.01771618.davem@davemloft.net>
References: <20070705231412.021359760@linux-foundation.org>
	<20070705231615.451797310@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43187
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752514AbXGEXmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 19:42:50 -0400
In-Reply-To: <20070705231615.451797310@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 05 Jul 2007 16:14:14 -0700

> The scatterlist only needs 16 bits for length/offset because
> PAGE_SIZE is 4K
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Unfortunately I don't think this can be done, even on i386.

It is legal to use order!=0 pages and multi-page areas in a single
scatterlist entry.


From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: question about drivers/net/ethernet/sgi
Date: Thu, 22 Aug 2013 15:16:17 +0200
Message-ID: <20130822131617.GZ2163@linux-mips.org>
References: <alpine.DEB.2.02.1308131742100.2263@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:43984 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123Ab3HVNQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 09:16:22 -0400
Received: from localhost.localdomain ([127.0.0.1]:46284 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S6852084Ab3HVNQVC3IY8 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Aug 2013 15:16:21 +0200
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1308131742100.2263@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 13, 2013 at 05:43:32PM +0200, Julia Lawall wrote:

> The files in drivers/net/ethernet/sgi (meth.c and ioc3-eth.c) both use
> alloc_skb.  Is there a reason why they do not use netdev_alloc_skb, like
> most other ethernet drivers?

netdev_alloc_skb is such newfangled (2.6.19) interface - and both of these
drivers date back to the 2.3 days.  So the answer is, nobody bothered so
far.

  Ralf

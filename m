From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: clk dereference in drivers/net/ethernet/ti/cpts.c
Date: Thu, 3 Jan 2013 15:00:00 +0100
Message-ID: <20130103140000.GA9656@localhost.localdomain>
References: <alpine.DEB.2.02.1301031040320.1989@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, tony@atomide.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:44270 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444Ab3ACOAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 09:00:10 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1301031040320.1989@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 03, 2013 at 11:20:52AM +0100, Julia Lawall wrote:
> There has been a discussion recently about how the result of get_clk
> should be an opaque handle, not a value that can be dereferenced:
> 
> https://lkml.org/lkml/2012/12/20/105
> 
> There is such a dereference in drivers/net/ethernet/ti/cpts.c, in the
> function cpts_clk_init:
> 
> cpts->freq = cpts->refclk->recalc(cpts->refclk);
> 
> It was not obvious to me, however, what API function should be used
> instead, so I am just reporting the (potential) problem.

This issue has been fixed in v3.8-rc2.

Thanks,
Richard

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [BUG] 3.11.5: IPv6 provoked oops?
Date: Fri, 20 Dec 2013 22:02:43 +0000
Message-ID: <20131220220243.GM4360@n2100.arm.linux.org.uk>
References: <20131220203115.GL4360@n2100.arm.linux.org.uk> <20131220204321.GA14073@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-gw.arm.linux.org.uk ([78.32.30.217]:35888 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753569Ab3LTWJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 17:09:53 -0500
Content-Disposition: inline
In-Reply-To: <20131220204321.GA14073@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 09:43:21PM +0100, Hannes Frederic Sowa wrote:
> On Fri, Dec 20, 2013 at 08:31:16PM +0000, Russell King - ARM Linux wrote:
> > So, I'm now running PPPoE on this box, which also does 6to4.  I tried
> > to ping another 6to4 address from a box on my lan, which caused this
> > oops from 3.11.5:
> 
> This should be fixed by the following patches:
> 
> http://patchwork.ozlabs.org/patch/288967/
> http://patchwork.ozlabs.org/patch/288970/
> 
> I think they reached stable already.

Thanks.  It seems I need the 3.12 stable branch for that.

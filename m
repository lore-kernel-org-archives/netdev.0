From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH] ipv6: add special mode forwarding=2 to send RS while
 configured as router
Date: Mon, 6 Dec 2010 06:26:41 -0500
Message-ID: <20101206112641.GD18994@canuck.infradead.org>
References: <20100903130420.GB28460@bombadil.infradead.org>
 <20101124180306.GA20862@srv03.cluenet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, davem@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:50312 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804Ab0LFL0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 06:26:43 -0500
Content-Disposition: inline
In-Reply-To: <20101124180306.GA20862@srv03.cluenet.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 24, 2010 at 07:03:06PM +0100, Daniel Roesen wrote:
> On Fri, Sep 03, 2010 at 09:04:20AM -0400, Thomas Graf wrote:
> > Similar to accepting router advertisement, the IPv6 stack does not send router
> > solicitations if forwarding is enabled.
> > 
> > This patch enables this behavior to be overruled by setting forwarding to the
> > special value 2.
> 
> Wouldn't it be more elegant to use accept_ra=2 as trigger instead of a new special
> value for the forwarding option?

Two reasons: I didn't want to change the behaviour of an existing
configuration option on which someone may rely on and I wanted to
allow sending of RS while still allowing to disable accepting RAs.

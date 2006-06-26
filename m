From: Christoph Hellwig <hch@infradead.org>
Subject: Re: -git: Why is drivers/net/wan/hdlc_generic.c:hdlc_setup() exported?
Date: Mon, 26 Jun 2006 10:35:35 +0100
Message-ID: <20060626093535.GA32072@infradead.org>
References: <200606260611.k5Q6BUSO017145@gw.wa3dbj.vix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:5064 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751145AbWFZJfs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 05:35:48 -0400
To: David Boggs <boggs@boggs.palo-alto.ca.us>
Content-Disposition: inline
In-Reply-To: <200606260611.k5Q6BUSO017145@gw.wa3dbj.vix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 25, 2006 at 11:11:30PM -0700, David Boggs wrote:
> [Resent because I forgot to copy netdev on my answer]
> 
> I asked Krzysztof to export that so that I could use it
> in a re-written driver for LMC WAN cards which I put out
> for comments on netdev in March.
> 
> I have incorporated the comments from the March posting and
> intend to repost the new driver very soon.  If you delete
> the export then I will have to write some nasty code to work
> around it.

Why can't you use alloc_hdlcdev?  


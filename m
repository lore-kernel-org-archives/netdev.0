From: thockin@hockin.org
Subject: Re: [PATCH] natsemi: Messages being noisy
Date: Thu, 14 Sep 2006 08:46:07 -0700
Message-ID: <20060914154607.GA7576@hockin.org>
References: <200609131528.51336.netdev@axxeo.de> <200609141739.08461.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from teetot.devrandom.net ([66.35.250.243]:39298 "EHLO
	teetot.devrandom.net") by vger.kernel.org with ESMTP
	id S1750788AbWINPqI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 11:46:08 -0400
To: Ingo Oeser <netdev@axxeo.de>
Content-Disposition: inline
In-Reply-To: <200609141739.08461.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 14, 2006 at 05:39:08PM +0200, Ingo Oeser wrote:
> Hi there,
> 
> Ingo Oeser wrote:
> > I  get the following message when trying to transfer big files 
> > (via FTP or SCP) since Linux 2.6.16.27. It didn't happen with Linux 2.6.13.4.
> > 
> > [702238.242237] eth1: increased tx threshold, txcfg 0xd0f01008.
> > [702238.242649] eth1: increased tx threshold, txcfg 0xd0f0100a.
> > 
> > What about putting this message at the message level "DEBUG"
> > or even under pr_debug()?
> 
> Now I even know, that this happens together with a small disruption 
> of traffic, which makes applications hang for a second or less.
> 
> Is it possible to have the maximum value right from the start?
> May I tune it somewhere to be the maximum from the start?
> 
> Would you accept patches for this?

This will (if I recall) increase transmit latency.  It's a fine line.  You
might tune it up, but this fallback path probably should not be removed..

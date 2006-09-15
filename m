From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH] natsemi: Messages being noisy
Date: Fri, 15 Sep 2006 10:11:38 +0200
Message-ID: <200609151011.39096.netdev@axxeo.de>
References: <200609131528.51336.netdev@axxeo.de> <200609141739.08461.netdev@axxeo.de> <20060914154607.GA7576@hockin.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:18357 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S1750717AbWIOIMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2006 04:12:03 -0400
To: thockin@hockin.org
In-Reply-To: <20060914154607.GA7576@hockin.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tim,
Hi Jeff,

thockin@hockin.org wrote:
> On Thu, Sep 14, 2006 at 05:39:08PM +0200, Ingo Oeser wrote:
> > Ingo Oeser wrote:
> > > I  get the following message when trying to transfer big files 
> > > (via FTP or SCP) since Linux 2.6.16.27. It didn't happen with Linux 2.6.13.4.
> > > 
> > > [702238.242237] eth1: increased tx threshold, txcfg 0xd0f01008.
> > > [702238.242649] eth1: increased tx threshold, txcfg 0xd0f0100a.
> > Is it possible to have the maximum value right from the start?
> > May I tune it somewhere to be the maximum from the start?
> 
> This will (if I recall) increase transmit latency.  It's a fine line.  You
> might tune it up, but this fallback path probably should not be removed..

Will implementing "ethtool_ringparam" be the right thing for this?

Or is there simply no ethtool mechanism for setting up thresholds, yet?

If not, I would simply like to have my original pr_debug patch included. 
The actual value of the tx threshhold can be queried 
via "ethtool -d eth0" already.

What do you think?


Regards

Ingo Oeser

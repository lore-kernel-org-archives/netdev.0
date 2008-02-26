From: Olof Johansson <olof@lixom.net>
Subject: Re: [patch 0/6] pasemi_mac updates for 2.6.26
Date: Tue, 26 Feb 2008 08:16:24 -0600
Message-ID: <20080226141624.GB22572@lixom.net>
References: <20080221025753.903665000@lixom.net> <18371.57542.77446.443231@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pasemi-linux@ozlabs.org, jgarzik@pobox.com,
	linuxppc-dev@ozlabs.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:49656 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754679AbYBZOMO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2008 09:12:14 -0500
Content-Disposition: inline
In-Reply-To: <18371.57542.77446.443231@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 26, 2008 at 08:49:58PM +1100, Paul Mackerras wrote:
> Olof Johansson writes:
> 
> > Here's a set of updates for pasemi_mac for 2.6.26. Some of them touch
> > the dma_lib in the platform code as well, but it's easier if it's all
> > merged through netdev to avoid dependencies.
> > 
> > Major highlights are jumbo frame support and ethtool basics, the rest
> > is mostly minor plumbing around it.
> 
> What route do you think these should take upstream?  I'm happy to take
> them if Jeff is OK with that.

I've sent them through Jeff in the past, that's been convenient when
there's been churn in the network APIs. I'm not sure if there's much of
that for .26 though.

If Jeff prefers to ACK, I'll just add it to my git and ask you to pull
that. But I was originally planning to just feed it through him.

(Note: I'll repost the patch set later today or tomorrow with a couple
of tweaks).


-Olof


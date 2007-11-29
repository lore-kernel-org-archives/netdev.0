From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Thu, 29 Nov 2007 13:45:54 -0800
Message-ID: <20071129134554.5c25a891@freepuppy.rosehill>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>
	<474C2246.50205@ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51007 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762479AbXK2VrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 16:47:23 -0500
In-Reply-To: <474C2246.50205@ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Nov 2007 14:57:26 +0100
Ariane Keller <ariane.keller@tik.ee.ethz.ch> wrote:

> I just wanted to ask whether there is a general interest in this patch.
> If yes: great, how to proceed?
> otherwise: please let me know why.
> 
> Thanks!
> 
> 
> 
> 
> Ariane Keller wrote:
> > Hi Stephen
> > 
> > Approximately a year ago we discussed an enhancement to netem,
> > which we called "trace control for netem".
> > 
> > We obtain the value for the packet delay, drop, duplication and 
> > corruption from a so called "trace file". The trace file may be obtained 
> > by monitoring network traffic and thus enables us to emulate "real 
> > world" network behavior.
> > 
> > Traces can ether be generated individually (we supply a set of tools to 
> > do this) or can be downloaded from our homepage: http://tcn.hypert.net .
> > 
> > Since our last submission on 2006-12-15 we did some code clean up and 
> > have created two new patches one against kernel 2.6.23.8 and one against 
> > iproute2-2.6.23.
> > To refer to our discussion from last year please have a look at messages 
> > with subject "LARTC: trace control for netem".
> > 
> > We are looking forward for any comments, suggestions and instructions to 
> > bring the trace enhancement to the kernel and to iproute2.
> > 
> > Thanks,
> > Ariane

Still interested in this. I got part way through integrating it but had
concerns about the API from the application to netem for getting the data.
It seemed like there ought to be a better way to do it that could handle large
data sets better, but never really got a good solution worked out (that is why
I never said anything).

The 2.6.23.8 patch seems to be unavailable right now.
-- 
Stephen Hemminger <shemminger@linux-foundation.org>

From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Thu, 21 Jun 2007 14:00:07 -0700
Message-ID: <1182459607.6096.31.camel@raj-laptop>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com>
	 <1181216629.4064.22.camel@localhost>  <20070619132148.GA32078@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, jamal <hadi@cyberus.ca>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:45631 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756984AbXFUVAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2007 17:00:13 -0400
In-Reply-To: <20070619132148.GA32078@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-06-19 at 17:21 +0400, Evgeniy Polyakov wrote:
> Hi.
> 
> On Thu, Jun 07, 2007 at 07:43:49AM -0400, jamal (hadi@cyberus.ca) wrote:
> > Folks, we need help. Please run this on different hardware. Evgeniy, i
> > thought this kind of stuff excites you, no? ;-> (wink, wink).
> > Only the sender needs the patch but the receiver must be a more powerful
> > machine (so that it is not the bottleneck).
> 
> I've ran several simple tests with desktop e1000 adapter I managed to
> find.
> 
> Test machine is amd athlon64 3500+ with 1gb of ram.
> Another point is dektop core duo 3.4 ghz with 2 gb of ram and sky2
> driver.
> 
> Simple test included test -> desktop and vice versa traffic with 128 and
> 4096 block size in netperf-2.4.3 setup.

Is that in conjunction with setting the test-specific -D to set
TCP_NODELAY, or was Nagle left-on?  If the latter, perhaps timing issues
could be why the confidence intervals weren't hit since the relative
batching of 128byte sends into larger segments is something of a race.

rick jones


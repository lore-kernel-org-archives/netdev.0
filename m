From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Tue, 21 Jun 2016 12:51:33 +0930
Message-ID: <20160621032133.GC19735@marvin.atrad.com.au>
References: <20151121223627.GA3493@electric-eye.fr.zoreil.com>
 <20151122225039.GE2957@marvin.atrad.com.au>
 <20151122230244.GA12249@electric-eye.fr.zoreil.com>
 <20151130064255.GL5537@marvin.atrad.com.au>
 <20151201235852.GA16429@electric-eye.fr.zoreil.com>
 <20160208023318.GJ9174@marvin.atrad.com.au>
 <20160407024417.GE17921@marvin.atrad.com.au>
 <20160517065231.GO30050@marvin.atrad.com.au>
 <20160518065137.GJ27564@marvin.atrad.com.au>
 <20160601003123.GE3384@marvin.atrad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.atrad.com.au ([150.101.241.2]:51933 "EHLO
	server.atrad.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752546AbcFUDVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 23:21:38 -0400
Received: from marvin.atrad.com.au (IDENT:1008@marvin.atrad.com.au [192.168.0.2])
	by server.atrad.com.au (8.14.9/8.14.9) with ESMTP id u5L3LXLn016621
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 12:51:35 +0930
Content-Disposition: inline
In-Reply-To: <20160601003123.GE3384@marvin.atrad.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

On Wed, Jun 01, 2016 at 10:01:23AM +0930, Jonathan Woithe wrote:
> On Wed, May 18, 2016 at 04:21:37PM +0930, Jonathan Woithe wrote:
> > On Thu, Apr 07, 2016 at 12:14:18PM +0930, Jonathan Woithe wrote:
> > > On Mon, Feb 08, 2016 at 01:03:19PM +1030, Jonathan Woithe wrote:
> > > > On Wed, Dec 02, 2015 at 12:58:52AM +0100, Francois Romieu wrote:
> > > > > Jonathan Woithe <jwoithe@atrad.com.au> :
> > > > > [...]
> > > > > > Any thoughts or progress at this stage?  Are there further tests you need me
> > > > > > to do ?
> > > > > 
> > > > > Yes but you should expect two more days without signal.
> > > > 
> > > > FYI I am now back from annual leave and linux.conf.au.  This means I am in
> > > > a position to test possible solutions to this problem once you are able to
> > > > make them available.
> > > 
> > > Has there been any further progress on this problem?  I still have access to
> > > the hardware and systems if further tests are required.
> > 
> > To assist in picking up this issue I thought I'd summarise where things are
> > at from my perspective.
> > 
> > The problem is that small low-speed UDP packets are being dropped by the
> > r8169-based network card in our systems.  Git bisect showed that the
> > regression started with commit da78dbff2e05630921c551dbbc70a4b7981a8fff.
> > :
> 
> FYI I have just tested the kernel.org 4.6 kernel and unsurprisingly it still
> exhibits the regression.

Is there any chance that this regression can be resolved?  It's been 6
months since the last contact was received from the list in relation to this
issue.  If the r8169 driver is to remain broken with respect to UDP traffic
then we will have no choice but to factor in a change in our standard
hardware for future systems.  Unfortunately this also means that dozens of
systems in the field cannot be upgraded to recent kernels since doing so
will trigger the regression.[1]

I would very much like to see the r8169 regression fixed and remain ready to
run more tests as needed.  I still have the test rig in place to recreate
the situation which triggers it, although it's likely the hardware will be
redeployed in the next few months.

If the decision has been made to leave the regression unfixed, please let me
know.  A least we will then understand the situation and we will stop waiting
for a solution which will never appear and start looking at changing our
standard hardware build.  For various reasons this is a significant
undertaking which we would rather not do and it has implications for ongoing
support of existing systems.  Obviously though if there's a bug in the r8169
kernel driver which will never be fixed then this is the approach we will
regrettably have to take.

Regards
  jonathan

[1] Exchanging network cards in existing systems just to avoid a kernel
regression is not a viable option because there are commercial software
licences node locked to the existing cards.  Finding a non-r8169 PCI card
for these systems may also prove to be a challenge.

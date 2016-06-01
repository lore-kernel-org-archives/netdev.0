From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Wed, 1 Jun 2016 10:01:23 +0930
Message-ID: <20160601003123.GE3384@marvin.atrad.com.au>
References: <20151120224534.GA25025@electric-eye.fr.zoreil.com>
 <20151121223627.GA3493@electric-eye.fr.zoreil.com>
 <20151122225039.GE2957@marvin.atrad.com.au>
 <20151122230244.GA12249@electric-eye.fr.zoreil.com>
 <20151130064255.GL5537@marvin.atrad.com.au>
 <20151201235852.GA16429@electric-eye.fr.zoreil.com>
 <20160208023318.GJ9174@marvin.atrad.com.au>
 <20160407024417.GE17921@marvin.atrad.com.au>
 <20160517065231.GO30050@marvin.atrad.com.au>
 <20160518065137.GJ27564@marvin.atrad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.atrad.com.au ([150.101.241.2]:42220 "EHLO
	server.atrad.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbcFAAbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 20:31:33 -0400
Content-Disposition: inline
In-Reply-To: <20160518065137.GJ27564@marvin.atrad.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2016 at 04:21:37PM +0930, Jonathan Woithe wrote:
> On Thu, Apr 07, 2016 at 12:14:18PM +0930, Jonathan Woithe wrote:
> > On Mon, Feb 08, 2016 at 01:03:19PM +1030, Jonathan Woithe wrote:
> > > On Wed, Dec 02, 2015 at 12:58:52AM +0100, Francois Romieu wrote:
> > > > Jonathan Woithe <jwoithe@atrad.com.au> :
> > > > [...]
> > > > > Any thoughts or progress at this stage?  Are there further tests you need me
> > > > > to do ?
> > > > 
> > > > Yes but you should expect two more days without signal.
> > > 
> > > FYI I am now back from annual leave and linux.conf.au.  This means I am in
> > > a position to test possible solutions to this problem once you are able to
> > > make them available.
> > 
> > Has there been any further progress on this problem?  I still have access to
> > the hardware and systems if further tests are required.
> 
> To assist in picking up this issue I thought I'd summarise where things are
> at from my perspective.
> 
> The problem is that small low-speed UDP packets are being dropped by the
> r8169-based network card in our systems.  Git bisect showed that the
> regression started with commit da78dbff2e05630921c551dbbc70a4b7981a8fff.
> :

FYI I have just tested the kernel.org 4.6 kernel and unsurprisingly it still
exhibits the regression.

Is there anything more I can do to move this forward?  I really do not want
to limit our systems to old kernels[1] just to avoid this regression, but
that is what I have to do while the regression remains.

Regards
  jonathan

[1] We are currently on 2.6.35.11 with some additional device driver patches
    we need for our hardware (which have subsequently been merged into
    mainline).  The regression is present in all kernels starting with 3.3
    which means the latest kernel we can use at present is 3.2.x.

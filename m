From: Chuck Anderson <cra@WPI.EDU>
Subject: Re: [E1000-devel] ixgbe: Unsupported SFP+ modules on 10Gbit/s
	X520-DA2 NIC?
Date: Wed, 18 Jan 2012 20:12:21 -0500
Message-ID: <20120119011221.GR5069@angus.ind.WPI.EDU>
References: <1326886258.19261.25.camel@probook> <20120118091351.000052fc@unknown> <m3d3ag7ki8.fsf@ursa.amorsen.dk> <9B4A1B1917080E46B64F07F2989DADD621FC38@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MAIL1.WPI.EDU ([130.215.36.91]:46868 "EHLO MAIL1.WPI.EDU"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755254Ab2ASBhX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jan 2012 20:37:23 -0500
Received: from MAIL1.WPI.EDU (MAIL1.WPI.EDU [130.215.36.91])
	by MAIL1.WPI.EDU (8.14.5/8.14.5) with ESMTP id q0J1CMFL018457
	for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 20:12:22 -0500
Received: from SMTP.WPI.EDU (SMTP.WPI.EDU [130.215.36.186])
	by MAIL1.WPI.EDU (8.14.5/8.14.5) with ESMTP id q0J1CM1H018454
	for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 20:12:22 -0500
Received: from angus.ind.WPI.EDU (ANGUS.IND.WPI.EDU [130.215.130.21])
	by SMTP.WPI.EDU (8.14.4/8.14.4) with ESMTP id q0J1CLUZ017372
	for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 20:12:22 -0500
	(envelope-from cra@WPI.EDU)
Received: from angus.ind.WPI.EDU (angus.ind.WPI.EDU [127.0.0.1])
	by angus.ind.WPI.EDU (8.14.2/8.14.2) with ESMTP id q0J1CL2R014986
	for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 20:12:21 -0500
Received: (from cra@localhost)
	by angus.ind.WPI.EDU (8.14.2/8.14.2/Submit) id q0J1CL1i014985
	for netdev@vger.kernel.org; Wed, 18 Jan 2012 20:12:21 -0500
Content-Disposition: inline
In-Reply-To: <9B4A1B1917080E46B64F07F2989DADD621FC38@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2012 at 10:21:58PM +0000, Fujinaka, Todd wrote:
> That's up to you. There's "locked" and there's "locked". I'm surprised
> that Benny and Jesper haven't looked at the driver to see where the
> messages come from.
> 
> We have a short list of optical modules that have been tested with our
> cards. The problem with standards is that there's always some wiggle
> room and you won't know if something really works until you try it. No
> matter how large the company, we are still constrained as far as what we
> can do in a day and testing every module we can find just wasn't one of
> the things that was approved for us to try.

I don't buy that argument.

We have Ethernet standards and we have IP standards and we have
SFP/SFP+ standards.  Did you test your 1000Base-T copper Ethernet
cards with every vendor of Ethernet hardware?  If not, did you lock
them out to talk to only "pre-approved" Ethernet switches?  Would you
have done so if there was a way to technically do so (perhaps via
LLDP)?

What about USB keyboards/mice?  Maybe Intel's chipsets can be locked
so only Intel USB keyboards work...and then we can all stop buying
Intel hardware.

The hardware and drivers should not be enforcing specific optics.  If
a user buys a crap optic, then that is their problem.  Just like if
they plug a crappy Cat3 RJ45 cable between the 1000Base-T NIC and the
switch.

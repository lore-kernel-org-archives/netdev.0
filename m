From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] tg3: add PCI error recovery support
Date: Fri, 12 Oct 2007 11:38:21 -0500
Message-ID: <20071012163821.GA11913@austin.ibm.com>
References: <20070718234826.GO5771@austin.ibm.com> <20070726225737.GK9876@austin.ibm.com> <1185498720.7922.85.camel@dell> <20070802231232.GL26837@austin.ibm.com> <1186100019.18322.77.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:34170 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933165AbXJLQip (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 12:38:45 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9CGcgED009195
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 12:38:42 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9CGcgLH493496
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 12:38:42 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9CGcW3M003072
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 12:38:32 -0400
Content-Disposition: inline
In-Reply-To: <1186100019.18322.77.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Aug 02, 2007 at 05:13:39PM -0700, Michael Chan wrote:
> On Thu, 2007-08-02 at 18:12 -0500, linas@austin.ibm.com wrote:
> > On Thu, Jul 26, 2007 at 06:12:00PM -0700, Michael Chan wrote:
> > > On Thu, 2007-07-26 at 17:57 -0500, linas@austin.ibm.com wrote:
> > > > [... PCI error recovery patches for tg3 ...]
> > > 
> > > Thanks.  We will review and submit probably in 2.6.24.
> > 
> > OK, thanks. Not to nag, but it helps to get these into susbsystem 
> > maintainer trees well before then, as otherwise the 2.6.24 window 
> > will get missed (seeing how I just missed 2.6.23 ..)
> 
> Yes, I know.  David Miller hasn't opened up a 2.6.24 tree yet.  We'll
> probably have a number of patches to be submitted for 2.6.24, and we'll
> add this one to the set.  Thanks.

Did the patch make it in?  Now seems to be the time ...

--linas

p.s. I'll send a generic MSI patch to the PCI mailing list; it appears 
the MSI issue is generic, affecting lots of adapters.


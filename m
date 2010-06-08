From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [PATCH][RFC] Infrastructure for out-of-band parameter passing
Date: Tue, 8 Jun 2010 11:36:16 -0700
Message-ID: <20100608183616.GB31503@dvomlehn-lnx2.corp.sa.net>
References: <20100608003049.GA29350@dvomlehn-lnx2.corp.sa.net> <20100608083120.e92a7739.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: to@dvomlehn-lnx2.corp.sa.net, netdev@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:23949 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140Ab0FHSgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 14:36:16 -0400
Content-Disposition: inline
In-Reply-To: <20100608083120.e92a7739.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 08, 2010 at 10:31:20AM -0500, Randy Dunlap wrote:
> On Mon, 7 Jun 2010 17:30:49 -0700 David VomLehn wrote:
> 
> > Infrastructure to support out of band/indirect passing of data to functions.
...
> > +/**
> > + * oobparam_push - push an out of band parameter frame on the OOB param stack
> > + * @head	Pointer to the OOB parameter stack top, which must be in the
> > + *		task structure.
> > + * @frame	Pointer to the OOB parameter frame, generally embedded in
> > + *		another structure
> 
> Need a colon ':' after the parameter names for kernel-doc notation:

That's what I get for relying on memory...thanks!
...
> ---
> ~Randy
> *** Remember to use Documentation/SubmitChecklist when testing your code ***

-- 
David VL

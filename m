From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Wed, 15 Aug 2007 12:59:15 -0700
Message-ID: <20070815195915.GL9645@linux.vnet.ibm.com>
References: <46BCC26B.6080600@redhat.com> <46BB46B2.60808@redhat.com> <20070809134150.GA14890@shell.boston.redhat.com> <2708.1186737826@redhat.com> <7680.1186822071@redhat.com> <46BFFDBD.6080804@redhat.com> <46C140DD.3060509@yahoo.com.au> <2cbda24e96a49c3ab7cf7039c515f9fc@kernel.crashing.org> <20070815191829.GJ9645@linux.vnet.ibm.com> <369924c4b3132a4b06258b7ac81b1006@kernel.crashing.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	linux-arch@vger.kernel.org, jesper.juhl@gmail.com, zlynx@acm.org,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	davem@davemloft.net, wensong@linux-vs.org, wjiang@resilience.com,
	David Howells <dhowells@redhat.com>
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:32798 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936137AbXHOT7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 15:59:19 -0400
Content-Disposition: inline
In-Reply-To: <369924c4b3132a4b06258b7ac81b1006@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 15, 2007 at 09:46:55PM +0200, Segher Boessenkool wrote:
> >>>Well if there is only one memory location involved, then smp_rmb()
> >>>isn't
> >>>going to really do anything anyway, so it would be incorrect to use 
> >>>it.
> >>
> >>rmb() orders *any* two reads; that includes two reads from the same
> >>location.
> >
> >If the two reads are to the same location, all CPUs I am aware of
> >will maintain the ordering without need for a memory barrier.
> 
> That's true of course, although there is no real guarantee for that.

A CPU that did not provide this property ("cache coherence") would be
most emphatically reviled.  So we are pretty safe assuming that CPUs
will provide it.

						Thanx, Paul

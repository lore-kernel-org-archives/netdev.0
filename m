From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [Alacrityvm-devel] [GIT PULL] AlacrityVM guest drivers for
	2.6.33
Date: Wed, 23 Dec 2009 10:22:21 -0800
Message-ID: <20091223182221.GA415@sequoia.sous-sol.org>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu> <20091223101340.GC20539@basil.fritz.box> <4B31EF65.6070000@redhat.com> <20091223121431.GF20539@basil.fritz.box> <1261590740.19822.94.camel@hermosa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Avi Kivity <avi@redhat.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>, torvalds@linux-foundation.org,
	Andrew Morton <akpm@linux-foundation.org>
To: "Peter W. Morreale" <pmorreale@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:42057 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755587AbZLWSXh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2009 13:23:37 -0500
Content-Disposition: inline
In-Reply-To: <1261590740.19822.94.camel@hermosa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Peter W. Morreale (pmorreale@novell.com) wrote:
> On Wed, 2009-12-23 at 13:14 +0100, Andi Kleen wrote:
> > > http://www.redhat.com/f/pdf/summit/cwright_11_open_source_virt.pdf
> > >
> > > See slide 32.  This is without vhost-net.
> > 
> > Thanks. Do you also have latency numbers?
> > 
> > It seems like there's definitely still potential for improvement
> > with messages <4K. But for the large messages they indeed 
> > look rather good.
> > 
> > It's unclear what message size the Alacrity numbers used, but I presume
> > it was rather large.
> 
> No.  It was 1500.  Please see: 
> 
> http://developer.novell.com/wiki/index.php/AlacrityVM/Results

That's just MTU.  Not the message size.  We can infer the message size by
the bare metal results (reasonably large), but is helpful to record that.

thanks,
-chris

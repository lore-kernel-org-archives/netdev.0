From: Paul Smith <paul@mad-scientist.net>
Subject: Re: Any implementation of NETPOLL for bonding?
Date: Tue, 16 Jun 2009 11:13:21 -0400
Message-ID: <1245165201.11148.244.camel@psmith-ubeta.netezza.com>
References: <1245101162.11148.210.camel@psmith-ubeta.netezza.com>
	 <20090615230907.GA8515@gospo.rdu.redhat.com>
Reply-To: paul@mad-scientist.net
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta.netezza.com ([12.148.248.132]:56366 "EHLO netezza.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754245AbZFPPNi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2009 11:13:38 -0400
In-Reply-To: <20090615230907.GA8515@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-06-15 at 19:09 -0400, Andy Gospodarek wrote:
> On Mon, Jun 15, 2009 at 05:26:02PM -0400, Paul Smith wrote:
> > I wanted to attach to my kernel with KGDBOE but failed because the
> > bonding driver doesn't support NETPOLL, and the only network access to
> > the system is over a bonded interface.
> 
> I did some work in the not-too-distant past on this and can probably
> dig-up the patches and port them to the latest upstream.  Would you be
> able to test a patch?

I can definitely test patches, but for my embedded systems I can't move
past 2.6.27.x.  I can make a stab at backporting whatever you have
though.

> It's a bit unclear to me why Jeff's patches were never accepted, but I
> suspect if there were many that didn't like them before, they won't be
> well received now, but it sure would be nice to use kgdb and use
> netconsole on bonding interfaces, wouldn't it? :-)

Yes, it so would :-).

I didn't see much objection to Jeff's patches.  There was one email from
Matt Mackall saying "Not really happy about how incestuous this makes
the bonding driver with netpoll. I'll try to think more about it over
the weekend." but there was no followup from Matt and I don't see a new
set of patches by Jeff (although I might have just missed them).


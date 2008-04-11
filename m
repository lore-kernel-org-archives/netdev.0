From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Fri, 11 Apr 2008 11:07:02 -0700 (PDT)
Message-ID: <20080411.110702.146231359.davem@davemloft.net>
References: <20080411143537.GA27874@2ka.mipt.ru>
	<47FF7CED.9090601@rtr.ca>
	<20080411151821.GA32398@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lkml@rtr.ca, ilpo.jarvinen@helsinki.fi, jesper.juhl@gmail.com,
	tilman@imap.cc, yoshfuji@linux-ipv6.org, jeff@garzik.org,
	rjw@sisk.pl, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34705
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760421AbYDKSHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 14:07:01 -0400
In-Reply-To: <20080411151821.GA32398@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 11 Apr 2008 19:18:21 +0400

> On Fri, Apr 11, 2008 at 10:59:57AM -0400, Mark Lord (lkml@rtr.ca) wrote:
> > >If you do not care about bug, why do you ever bothered filling it?
> > ..
> > 
> > Because I care, about Linux's reputation and performance.
> > I care about basic networking operations, and knew that this bug
> > would probably affect other applications once widely deployed.
> > 
> > I care about Linux.  That's why.
> 
> Blah-blah-blah, you care so much, that pissed people off which suggested
> you how to really help Linux. And then you returned with besiect
> results. You helped, but if you just cared, you had missed first part.

Every time I see someone play the "I care about Linux" card, they are
typically being a hypocrit.  It's a knee jerk, defensive gesture, and
usually has absolutely zero substance.

> > The current generation of kernel "code submitters" here
> > seems to have never learned those.  Bummer.
> 
> Next time I will ask soothsayer, she really knows how to debug network
> bug with following description: "it worked before I changed a kernel
> version. you have to return my puppets back".

Thanks for your support Evgeniy, it is truly appreciated.

We had Mark's bug fixed in 15 minutes once the bisect result was
known, even after Ilpo and myself had scanned through the changesets.

This proves the utility of bisect and in fact that trying to intuit
the cause by continuing to study changesets and code would have been a
complete waste of time.

Yes, Mark, we used to do things that way for every bug in the kernel.
And as a result many bugs sat unfixed for weeks if not months.  Many
of us have left the cave, feel free to join us.

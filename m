From: David Brownell <david-b@pacbell.net>
Subject: Re: [patch 2.6.24-git] net/enc28j60: oops fix, low power mode
Date: Sun, 10 Feb 2008 09:54:18 -0800
Message-ID: <200802100954.18225.david-b@pacbell.net>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <200802062156.41862.david-b@pacbell.net> <47AAE32A.7070105@eptar.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp123.sbc.mail.sp1.yahoo.com ([69.147.64.96]:39178 "HELO
	smtp123.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751993AbYBJRyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 12:54:21 -0500
In-Reply-To: <47AAE32A.7070105@eptar.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 07 February 2008, Claudio Lanconelli wrote:
> David Brownell wrote:
> > How long did that take?  I did about four dozen
> >
> > 	ifconfig eth1 up
> > 	sleep 3
> > 	ifconfig eth1 down
> >
> > cycles ... it worked fine.  The "sleep" was to let the link
> > negotiation complete.
> >
> >   
> After a couple of :
> 
> ifconfig eth0 down
> (wait just 1 second)
> ifconfig eth0 up
> 
> the network is frozen.
> 
> If I do another
> ifconfig eth0 down
> (wait just 1 second)
> ifconfig eth0 up
> 
> restarts.
> It's random, no rule.

I write a shell loop to do that, and added a "ping -c2" too.
If that was done before the "sleep 1" no packets flowed.
Afterwards, no problem -- ever. 

(And outside the loop, "ethool -s eth1 duplex full".)

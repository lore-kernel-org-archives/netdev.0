From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: iproute2: resend of patches from Debian.
Date: Thu, 11 Oct 2007 21:59:56 +0200
Message-ID: <1192132796.4733.7.camel@localhost.localdomain>
References: <1192127132.4732.9.camel@localhost.localdomain>
	 <20071011192509.GA4004@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Alexander Wirt <formorer@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:55648 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754110AbXJKUAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 16:00:51 -0400
In-Reply-To: <20071011192509.GA4004@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On tor, 2007-10-11 at 15:25 -0400, Lennart Sorensen wrote:
> On Thu, Oct 11, 2007 at 08:25:32PM +0200, Andreas Henriksson wrote:
> > Patch from debian iproute package.
> > 
> > diff -urNad iproute-20060323~/ip/iplink.c iproute-20060323/ip/iplink.c
> > --- iproute-20060323~/ip/iplink.c	2006-03-22 00:57:50.000000000 +0100
> > +++ iproute-20060323/ip/iplink.c	2006-09-08 21:07:14.000000000 +0200
> > @@ -384,6 +384,10 @@
> >  	}
> >  
> >  	if (newname && strcmp(dev, newname)) {
> > +		if (strlen(newname) == 0) {
> > +		    printf("\"\" is not valid device identifier\n",dev);
> > +		    return -1;
> > +		}
> >  		if (do_changename(dev, newname) < 0)
> >  			return -1;
> >  		dev = newname;
> 
> Isn't that printf missing somewhere for the 'dev' argument to go?

This is not my patch so I don't know what the original intention was,
but now that you point it out I'd say that the dev argument should just
be removed.
The new check is for an empty new name.... old name (dev) probably isn't
interesting.

I think Alexander Wirt is the original author, lets CC and see if he has
a comment...

-- 
Regards,
Andreas Henriksson


From: Alexander Wirt <formorer@formorer.de>
Subject: Re: iproute2: resend of patches from Debian.
Date: Fri, 12 Oct 2007 07:55:40 +0200
Message-ID: <20071012055540.GF30784@ned.snow-crash.org>
References: <1192127132.4732.9.camel@localhost.localdomain> <20071011192509.GA4004@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Henriksson <andreas@fatal.se>, netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadowland.snow-crash.org ([80.190.250.253]:34446 "EHLO
	ned.snow-crash.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758855AbXJLGQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 02:16:29 -0400
Content-Disposition: inline
In-Reply-To: <20071011192509.GA4004@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennart Sorensen schrieb am Donnerstag, den 11. Oktober 2007:

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
Uhm, yes you are right. It don't hurts but its useless, so the 'dev' argument
should be removed. 

Thanks
Alex


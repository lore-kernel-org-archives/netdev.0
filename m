From: jb <jb.1234abcd@gmail.com>
Subject: Re: [PATCH] iputils: fix memory leaks
Date: Thu, 7 Mar 2013 11:18:21 +0000 (UTC)
Message-ID: <loom.20130307T121410-568@post.gmane.org>
References: <loom.20130307T103516-549@post.gmane.org> <AE90C24D6B3A694183C094C60CF0A2F6026B7181@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:59938 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932235Ab3CGLSl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 06:18:41 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UDYqi-0005zY-GC
	for netdev@vger.kernel.org; Thu, 07 Mar 2013 12:19:00 +0100
Received: from 79-139-19-75.prenet.pl ([79.139.19.75])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 12:19:00 +0100
Received: from jb.1234abcd by 79-139-19-75.prenet.pl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 12:19:00 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight <David.Laight <at> ACULAB.COM> writes:

> 
> >     Fix memory leaks
> ...
> > +#ifdef USE_IDN
> > +                               free(idn);
> > +                               idn = NULL;
> > +#endif
> >                                 exit(2);
> 
> There is no point calling free() before exit(), nor any need
> to free items that aren't allocated inside loops.
> 
> 	David

A matter of good style ? Overzealous ?
Flame ?
http://stackoverflow.com/questions/654754/what-really-happens-when-you-dont-free-after-malloc
jb

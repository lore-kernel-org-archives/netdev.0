From: "evan foss" <evanfoss@gmail.com>
Subject: Re: [PATCH V2] bcm43xx: Fix failure to deliver PCI-E interrupts
Date: Thu, 18 Jan 2007 07:52:39 -0500
Message-ID: <4a55afb80701180452y62b41586xfc56467030e0c0c6@mail.gmail.com>
References: <45a7ceb2.m02aaCgouBsadVk/%Larry.Finger@lwfinger.net>
	 <1168881379.2481.46.camel@flanders.rdu.redhat.com>
	 <45ABC0D5.3060008@lwfinger.net>
	 <4a55afb80701151502q7bf8bbabp7507a42f072efd29@mail.gmail.com>
	 <45AC41C4.2070401@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:4287 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932231AbXARMwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jan 2007 07:52:40 -0500
Received: by wr-out-0506.google.com with SMTP id 68so146452wra
        for <netdev@vger.kernel.org>; Thu, 18 Jan 2007 04:52:39 -0800 (PST)
To: netdev@vger.kernel.org, Bcm43xx-dev@lists.berlios.de
In-Reply-To: <45AC41C4.2070401@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> One thing I forgot is that the LED will be on only if the switch is in the on position _AND_ the
> interface is UP.

Yes I figured that out. (eventually)

> >>> dhcpcd eth1           <-low transmit power???
> >> Most likely. How far are you from the AP?
> >
> > This is a timeout issue. I tried to apply the timeout patch which I
> > assume is for this and it didn't take. I have logs for both patch
> > applications below. To the distance issue my ap died so I am trying to
> > just connect to one next door. (with permission) The distance is about
> > 50ft. So this could be the main factor. This is why I said it might be
> > my fault. The thing is I can connect to it in windows most of the time
> > so I know it is in range. I will be going to school on Tuesday and
> > will report back then. They have a much better AP.
>
> With the current transmit levels of the 4311, 50 feet through at least one wall is probably too much.

I have tried 3 more AP at much closer distances <9ft and <4ft and it
still won't work. I ether get "Network Down" or a timeout.


> > Presario1600 bcm43xx # patch -p0 <patch_2.6.18.1_signal_quality
...
> > Presario1600 bcm43xx # patch -p0 <patch_2.6.18.1_watchdog_timeout2
...
> Those patches are already applied to your code.

Thanks for the clarification, and assistance.

-- 
http://www.coe.neu.edu/~efoss/
http://evanfoss.googlepages.com/

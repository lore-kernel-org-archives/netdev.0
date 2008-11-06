From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Subject: Re: UNIX sockets kernel panic
Date: Thu, 6 Nov 2008 15:14:34 +0000
Message-ID: <20081106151434.GA4968@shorty>
References: <20081106001445.GA5595@shorty> <20081106011319.GA22389@x200.localdomain> <20081105.171822.193705306.davem@davemloft.net> <20081106.042600.114065285.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:60790 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbYKFPN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 10:13:29 -0500
Received: by ey-out-2122.google.com with SMTP id 6so266969eyi.37
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2008 07:13:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081106.042600.114065285.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm still seeing problems with your patch.  I'm getting mixed results.
With SMP off, everything seems to work.  With SMP, on my laptop, it
still barfs (.26 and .27).  Here's a screenshot (literally) of .26:
http://darkircop.org/unix.jpg

I can't seem to reproduce it on qemu using -smp.  However, on qemu, with
kernel 2.6.19, your patch, and -smp 2, I can get this one to hang:
http://darkircop.org/unix2.c

On my laptop, with 2.6.19 and SMP on, I think that everything works.
It's likely that it's a scheduling / configuration problem, so I
don't think there's anything magic in .19.

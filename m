From: olof@lixom.net (Olof Johansson)
Subject: Re: [RESEND] [PATCH v2] [3/5] pasemi_mac: cleanups and rx performance improvements
Date: Sat, 28 Apr 2007 15:08:46 -0500
Message-ID: <20070428200846.GB2442@lixom.net>
References: <20070428054952.GA22074@lixom.net> <20070428055112.GD22074@lixom.net> <463366C3.7020701@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:56444 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754142AbXD1UIK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 16:08:10 -0400
Content-Disposition: inline
In-Reply-To: <463366C3.7020701@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 28, 2007 at 11:22:43AM -0400, Jeff Garzik wrote:
> Olof Johansson wrote:
> >NAPI fixes and cleanups for pasemi_mac:
> >
> >* Timer changes/fixes
> >* Abstract out the rx intr restart to a separate function
> >* Similar function for tx intr to reset to a known clear state even if
> >  firmware used the same interface
> >* Add a copy-break and recycle the SKB in the driver for small
> >  packets
> >* Other minor changes to rx path
> 
> Split out the "abstract out function foo" style changes into a separate 
> patch.
> 
> This creates a smaller and much more reviewable second patch as a 
> result.  Doing so also creates a nice, clean git-bisect point that can 
> be used to guarantee the validity of the first patch.

Ok, I was really asking for this one...

Even that didn't result in that much of a more readible patch.

I've split it up in a total of 5. I'll repost the series shortly.


Thanks,

-Olof

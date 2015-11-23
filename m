From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Mon, 23 Nov 2015 10:37:33 +1030
Message-ID: <20151123000733.GF2957@marvin.atrad.com.au>
References: <20130405001526.GC19253@marvin.atrad.com.au>
 <20151117015605.GI22941@marvin.atrad.com.au>
 <20151117232108.GC3362@electric-eye.fr.zoreil.com>
 <20151118050919.GR25216@marvin.atrad.com.au>
 <20151119005608.GB4882@electric-eye.fr.zoreil.com>
 <20151120024616.GL7136@marvin.atrad.com.au>
 <20151120224534.GA25025@electric-eye.fr.zoreil.com>
 <20151121223627.GA3493@electric-eye.fr.zoreil.com>
 <20151122225039.GE2957@marvin.atrad.com.au>
 <20151122230244.GA12249@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.atrad.com.au ([150.101.241.2]:43275 "EHLO
	server.atrad.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752745AbbKWAHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 19:07:41 -0500
Content-Disposition: inline
In-Reply-To: <20151122230244.GA12249@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 23, 2015 at 12:02:44AM +0100, Francois Romieu wrote:
> Jonathan Woithe <jwoithe@atrad.com.au> :
> [...]
> > I'm a little confused though as to which patch you want me to apply.  There
> > was an inline patch against r8169.c in your message, and then there was
> > another patch to r8169.c in the form of an attachment.  Both patches removed
> > the include of asm/system.h but the rest of the content differs.  Did you
> > want each tried in turn?  Apologies if I'm missing something obvious.
> 
> Use the inlined one. I forgot to remove the 2.6.35.11 based attachment.

Ok, no problem.

That's done now and it appears to work.  That is, I am not seeing any of the
erroneous UDP packet delivery problems noted previously and therefore the
communication with the external device is working normally.

I dropped the patched r8169.c into a 4.3.0 kernel since that's what I
already had on the system.

Regards
  jonathan

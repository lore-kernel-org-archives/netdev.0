From: Andi Kleen <ak@suse.de>
Subject: Re: Using netconsole for debugging suspend/resume
Date: Mon, 12 Jun 2006 13:21:30 +0200
Message-ID: <200606121321.30388.ak@suse.de>
References: <44886381.9050506@goop.org> <200606090546.15923.ak@suse.de> <448992B7.1050906@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Matt Mackall <mpm@selenic.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:37265 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1751873AbWFLLVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 07:21:55 -0400
To: Mark Lord <lkml@rtr.ca>
In-Reply-To: <448992B7.1050906@rtr.ca>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 09 June 2006 17:24, Mark Lord wrote:
> Andi Kleen wrote:
> > 
> > If your laptop has firewire you can also use firescope.
> > (ftp://ftp.suse.com/pub/people/ak/firescope/) 
> ..
> > FW keeps running as long as nobody resets the ieee1394 chip.
> 
> This looks interesting.  But how does one set it up for use
> on the *other* end of that firewire cable?  The Quickstart and
> manpage don't seem to describe this fully.

It's in the manpage:

>.SH NOTES
>The target must have the ohci1394 driver loaded. This implies
>that firescope cannot be used in early boot.

That's it.

-Andi

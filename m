From: Jeff Garzik <jeff@garzik.org>
Subject: Re: odd RTL8139 quirk.
Date: Tue, 29 Apr 2008 18:33:02 -0400
Message-ID: <4817A21E.2090906@garzik.org>
References: <20080429171403.GA21035@redhat.com> <48177905.4000409@garzik.org> <20080429215626.GC2859@redhat.com> <48179B56.7000606@garzik.org> <20080429221011.GD2859@redhat.com> <48179F02.6020309@garzik.org> <20080429222804.GE2859@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38910 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752551AbYD2Wdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 18:33:49 -0400
In-Reply-To: <20080429222804.GE2859@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones wrote:
> On Tue, Apr 29, 2008 at 06:19:46PM -0400, Jeff Garzik wrote:
>  > Dave Jones wrote:
>  > >>From a quick eyeball, that would seem that it still requires a choice
>  > > to be made whether or not to enable CONFIG_8139TOO_PIO
>  > > What I had in mind was to make that whole USE_IO_OPS ifdef
>  > > (and related bits) if (modparm==.. instead of #ifdefs.
>  > 
>  > 
>  > The patch is the requisite groundwork to add such a module param... 
>  > iomap support is required to enable runtime rather than compile-time 
>  > MMIO/PIO switching.
>  > 
>  > e100 does this with the 'use_io' module param.
> 
> Ah, in which case, I endorse this proposal heartily :)

Is that endorsement perchance accompanied by the time to resurrect the 
patch?  :)

Also, specifically with your hardware, one would hope we could figure 
out some automatic way for the driver to detect the hardware and 
configure it accordingly.

	Jeff





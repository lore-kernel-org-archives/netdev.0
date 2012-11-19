From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 080/493] fddi: remove use of __devexit_p
Date: Mon, 19 Nov 2012 18:57:39 +0000
Message-ID: <1353351459.4156.5.camel@bwh-desktop.uk.solarflarecom.com>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
	 <1353349642-3677-80-git-send-email-wfp5p@virginia.edu>
	 <alpine.LFD.2.02.1211191842180.25230@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Bill Pemberton <wfp5p@virginia.edu>, <gregkh@linuxfoundation.org>,
	<netdev@vger.kernel.org>
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32833 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018Ab2KSS5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:57:42 -0500
In-Reply-To: <alpine.LFD.2.02.1211191842180.25230@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-19 at 18:49 +0000, Maciej W. Rozycki wrote:
> On Mon, 19 Nov 2012, Bill Pemberton wrote:
> 
> > CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
> > needed.
> 
>  Shouldn't this be switching to __exit_p() instead?  Likewise all the 
> other changes concerned (i.e. s/__dev\(init\|exit\)/__\1/), for the sake 
> of drivers built into the kernel proper (yes, there are people out there 
> still doing that).  Am I missing something?

Drivers can be unbound by poking in sysfs.

Ben.

>  This change scores my NAK as it stands, until updated accordingly or 
> further justified.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

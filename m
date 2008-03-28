From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: Oops/Warning report for the week of March 28th 2008
Date: Fri, 28 Mar 2008 23:14:58 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0803282309040.32241@twin.jikos.cz>
References: <47ED3F1A.1090101@linux.intel.com>
 <alpine.LFD.1.00.0803281310480.14670@woody.linux-foundation.org>
 <alpine.LFD.1.00.0803281329340.14670@woody.linux-foundation.org>
 (sfid-20080328_205203_254278_BF9EB41F) <1206738071.22530.80.camel@johannes.berg>
  <alpine.LFD.1.00.0803281418570.14670@woody.linux-foundation.org>
 <1206740581.22530.83.camel@johannes.berg> <alpine.LFD.1.00.0803281500100.14670@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>, Dmitry Torokhov <dtor@mail.ru>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twin.jikos.cz ([213.151.79.26]:54723 "EHLO twin.jikos.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758713AbYC1WP2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 18:15:28 -0400
In-Reply-To: <alpine.LFD.1.00.0803281500100.14670@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Mar 2008, Linus Torvalds wrote:

> > I tend to think it's actually a regression, I've done exactly what I 
> > described there dozens of times before on older kernels and it doesn't 
> > seem to be a race condition, X always locks the input device and I 
> > never had trouble with that before.
> Ahh. So it's easily repeatable for you.. Do you think you could bisect it? 
> At least a few runs? Even a partial bisection will give a nice (== much 
> smaller) range of commits to be blamed, and might tell us why it started 
> happening..

... and if bisecting the whole tree isn't the way for you to go right now, 
maybe restricting to drivers/input/ and drivers/base/ (as I think this 
might be some broken driver core refcounting) and possibly drivers/hid/ 
(if you are using any HID input device) might also be sufficient.

-- 
Jiri Kosina
SUSE Labs


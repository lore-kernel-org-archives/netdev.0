From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Oops/Warning report for the week of March 28th 2008
Date: Fri, 28 Mar 2008 14:24:30 -0700 (PDT)
Message-ID: <alpine.LFD.1.00.0803281418570.14670@woody.linux-foundation.org>
References: <47ED3F1A.1090101@linux.intel.com>  <alpine.LFD.1.00.0803281310480.14670@woody.linux-foundation.org>  <alpine.LFD.1.00.0803281329340.14670@woody.linux-foundation.org>  (sfid-20080328_205203_254278_BF9EB41F)
 <1206738071.22530.80.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>, Dmitry Torokhov <dtor@mail.ru>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35790 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753491AbYC1VZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:25:07 -0400
In-Reply-To: <1206738071.22530.80.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 28 Mar 2008, Johannes Berg wrote:
> 
> That I've seen before, analysed a bit and posted:
> http://permalink.gmane.org/gmane.linux.kernel.input/4281

Ahh.. And this is presumably triggered either by some new Xorg behavior in 
fc9 or just the scheduler timing changes that caused other things too?

Your suggested solution sounds ok, but I'm also wondering why those things 
aren't properly refcounted? It does sound like a bug to free the thing 
before all users are gone - regardless of anything else. Hmm?

But the ungrab sounds like the best short-term fix. Do we have a patch for 
testing? Please? It's pretty late in the 2.6.25 cycle for these kinds of 
things..

		Linus

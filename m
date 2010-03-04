From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RESEND PATCH 0/2] Make functions of dev_<level> macros, recursive
 vsnprintf
Date: Thu, 4 Mar 2010 15:06:17 -0800 (PST)
Message-ID: <alpine.LFD.2.00.1003041504080.3751@localhost.localdomain>
References: <cover.1267682641.git.joe@perches.com> <20100304143837.af39845d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joe Perches <joe@perches.com>, Nick Andrew <nick@nick-andrew.net>,
	linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39481 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754137Ab0CDXG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 18:06:26 -0500
In-Reply-To: <20100304143837.af39845d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 4 Mar 2010, Andrew Morton wrote:
> 
> What would I need to do to make it recur more than once?  Include a %pV
> in a string, like dev_printk("%s", %%pV")?

I would argue that if somebody does that, they're just broken.

The single level of recursion is really nice - it solves a real annoyance. 
But if somebody starts trying to do multiple levels, that's just crazy.

Of course, I guess we don't relly have any way of sanely _counting_ the 
recursion level, so we'd have to just trust people to not do crazy things. 

And that's a big thing to take on trust ;)

			Linus

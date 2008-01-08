From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Tue, 8 Jan 2008 11:31:19 -0800 (PST)
Message-ID: <alpine.LFD.1.00.0801081126200.3148@woody.linux-foundation.org>
References: <477FF149.4070609@linux.intel.com> <20080105213935.GN27894@ZenIV.linux.org.uk> <20080107174431.GC27741@fieldses.org> <4782CF9C.6000508@gmail.com> <alpine.LFD.1.00.0801071851120.3148@woody.linux-foundation.org> <20080108081401.d9576ac5.randy.dunlap@oracle.com>
 <4783B602.1050307@linux.intel.com> <alpine.LFD.1.00.0801080957280.3148@woody.linux-foundation.org> <4783BE06.1070507@linux.intel.com> <alpine.LFD.1.00.0801081025470.3148@woody.linux-foundation.org> <4783C95C.7050303@linux.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Kevin Winchester <kjwinchester@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52086 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756956AbYAHTdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 14:33:12 -0500
In-Reply-To: <4783C95C.7050303@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 8 Jan 2008, Arjan van de Ven wrote:
> 
> ok done; I had to fizzle a bit because some things aren't *exactly* a 
> BUG() statement but I track them anyway (things like the "sleeping in 
> invalid context" check), so I had to somewhat arbitrarily assign 
> categories for those. I might fine tune these over time some; if you or 
> someone else sees problems with categorization please let me know

Looking good. I wonder if we could also have some way to cross-ref these 
things with the regression list (notably try to get pointers to them in 
the regression list). 

Right now, the regression list keeps track of the things that are closed, 
but kerneloops.org obviously doesn't see that, so it's not obvious which 
oopses are "uninteresting" since they've been fixed.

			Linus

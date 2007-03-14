From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] avoid OPEN_MAX in SCM_MAX_FD
Date: Tue, 13 Mar 2007 18:15:29 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0703131814160.9690@woody.linux-foundation.org>
References: <20070314005508.DDC121801C5@magilla.sf.frob.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Benjamin LaHaise <bcrl@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Roland McGrath <roland@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:47841 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932529AbXCNBPq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 21:15:46 -0400
In-Reply-To: <20070314005508.DDC121801C5@magilla.sf.frob.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 13 Mar 2007, Roland McGrath wrote:
> 
> Ok, fine.  But PATH_MAX is a real constant that has some meaning in the
> kernel.  It's perfectly correct to use PATH_MAX as a constant on a system
> like Linux that defines it and means what it says.  Conversely, OPEN_MAX
> has no useful relationship with anything the kernel is doing at all.

Sure. I'm just saying that some people may use OPEN_MAX the way I know 
people use PATH_MAX - whether it's what you're supposed to or not.

I do agree that PATH_MAX is much more appropriate to be used that way, and 
is more likely to have "real" meaning, I just worry.

		Linus

From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Thu, 8 May 2008 18:51:08 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0805081848170.2940@woody.linux-foundation.org>
References: <20080508.171408.94456716.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51254 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762772AbYEIBvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 21:51:42 -0400
In-Reply-To: <20080508.171408.94456716.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 8 May 2008, David Miller wrote:
> 
> Here are some networking fixes and enhancements:

David, you need to stop sending patches like this after -rc1.

This is too big. I'm taking it, but there's something wrong in this. Your 
merges after -rc1 have generally been way too large, and I need to shut 
you down if this gets to be a big pattern.

It's one thing taking a totally new driver (that couldn't have worked 
before and cannot be a regression) or adding new PCI ID's. It's a totally 
different thing to take 800 lines of code to an old driver that people 
depend on. These things need to happen during the merge window, and just 
because they are drivers doesn't mean that they can just do anythign they 
want.

		Linus

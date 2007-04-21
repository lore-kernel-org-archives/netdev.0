From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Eliminate some unnecessary gotos in tcp v4 hash
 handling
Date: Fri, 20 Apr 2007 17:20:59 -0700 (PDT)
Message-ID: <20070420.172059.128617283.davem@davemloft.net>
References: <200704051248.44989.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ak@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56379
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753493AbXDUAUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 20:20:55 -0400
In-Reply-To: <200704051248.44989.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Thu, 5 Apr 2007 12:48:44 +0200

> 
> The compiler eliminates them anyways and this makes the code easier to read
> and shorter.
> 
> Signed-off-by: Andi Kleen <ak@suse.de>

Actually I won't apply this patch, ever, -ENOCOMPILE.

Andi, please spare me with these patches if you won't even bother
trying to compile them.  It doesn't matter how easy to read the code
is if it doesn't build. :-/

I found this build failure just by reviewing your patch for
correctness, I didn't even need to give it to the compiler to see that
you left the "cur = NULL; goto out;" case in there yet removed the
"out" label.

Don't bother posting the fixed version, I'll ignore it.  You just
basically proved how pointless this patch is, and how little you
yourself even care about it.

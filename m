From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Make the synchronization interval controllable
Date: Thu, 7 Feb 2008 13:28:09 +0900
Message-ID: <20080207042808.GA6211@verge.net.au>
References: <Pine.LNX.4.64.0802062329150.15729@titan.stealer.net> <1202342263-25176-1-git-send-email-sven.wegener@stealer.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sven Wegener <sven.wegener@stealer.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:34137 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755490AbYBGE2R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 23:28:17 -0500
Content-Disposition: inline
In-Reply-To: <1202342263-25176-1-git-send-email-sven.wegener@stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 07, 2008 at 12:57:43AM +0100, Sven Wegener wrote:
> The default synchronization interval of 1000 milliseconds is too high for a
> heavily loaded director. Collecting the connection information from one second
> and then sending it out in a burst will overflow the socket buffer and lead to
> synchronization information being dropped. Make the interval controllable by a
> sysctl variable so that users can tune it. We enforce a lower limit of 0 and an
> upper limit of 2000 ms on the interval. A too large interval can make the
> synchronization buffer consume too much memory and will also delay the exit of
> the kernel threads.
> 
> Signed-off-by: Sven Wegener <sven.wegener@stealer.net>

Hi Sven,

I have no problems with the spirit of this patch, and the range checking
seems good to me.  Though I wonder if 2000 might not be an exessively
low maximum.  I can't think of a usage case off-hand, but I'm not sure I
understand why a user shouldn't be able to set it to much (rediculously)
higher values.

In any case, thats not a big deal.

Acked-by: Simon Horman <horms@verge.net.au>

> ---
> 
> Changes from the last version include the addition of the range enforcement.
> Also place the definitions of the variables where all other ipvs sysctl
> variables are.

-- 
Horms


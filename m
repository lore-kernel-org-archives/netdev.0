From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH 1/2] IPV4: remove addresses and routes when carrier is lost
Date: Tue, 3 Jun 2008 17:45:27 -0400
Message-ID: <20080603214527.GG16162@csclub.uwaterloo.ca>
References: <20080602165249.52a467dc@extreme> <20080603150524.GA16165@csclub.uwaterloo.ca> <20080603085707.51fdabbb@speedy> <48456B62.8050909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:55068 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757886AbYFCVp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 17:45:28 -0400
Content-Disposition: inline
In-Reply-To: <48456B62.8050909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 06:03:46PM +0200, Patrick McHardy wrote:
> Can't the routing daemon simply ignore routes with a
> device that has no carrier?

zebra won't add a route that is already provided by the kernel.  The
kernel has to remove it's route when the link is down before zebra can
provide an alternative.

-- 
Len Sorensen

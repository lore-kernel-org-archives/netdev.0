From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH 2/2] ipv4: factorize cache clearing for batched unregister operations
Date: Tue, 17 Nov 2009 09:22:08 +0200
Message-ID: <200911170922.08486.opurdila@ixiacom.com>
References: <200911170149.50011.opurdila@ixiacom.com> <20091116160646.39c0a1ac@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:21923 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755326AbZKQHZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 02:25:33 -0500
In-Reply-To: <20091116160646.39c0a1ac@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 17 November 2009 02:06:46 you wrote:
> On Tue, 17 Nov 2009 01:49:49 +0200
> 
> Octavian Purdila <opurdila@ixiacom.com> wrote:
> > Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> > ---
> >  net/ipv4/fib_frontend.c |   11 ++++++-----
> >  1 files changed, 6 insertions(+), 5 deletions(-)
> 
> And what about IPV6?
> 

IPv6 did not appear during profiling my simple dummy test and also a quick scan 
through the code did not reveal anything obvious on the unregister path which 
could be factorized.

BTW, it appears we don't have a route cache for IPv6. Right?

I known we will run into other scalability issues when we  will set IPv4/IPv6 
addresses, and that is one of the next items on my list to profile :)


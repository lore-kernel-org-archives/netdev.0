From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] socket: SOCK_DEBUG type checking
Date: Fri, 21 Mar 2008 17:17:31 -0700
Message-ID: <20080321171731.2447b435@extreme>
References: <20080321075132.2fe4ac23@extreme>
	<20080321.155600.121386813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:49002 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752415AbYCVARj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2008 20:17:39 -0400
In-Reply-To: <20080321.155600.121386813.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Mar 2008 15:56:00 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Fri, 21 Mar 2008 07:51:32 -0700
> 
> > Use the inline trick (same as pr_debug) to get checking
> > of debug statements even if no code is generated.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Applied, and I'll push to net-2.6.26 after some build
> testing.
> 
> Although the use of SOCK_DEBUG is so esoteric and sparse,
> I can't see how any of it can be useful for any kind of
> debugging.
> 
> I'd say we should just remove this thing.

Agreed, that was the other alternative, just saw it while
looking at filter stuff.

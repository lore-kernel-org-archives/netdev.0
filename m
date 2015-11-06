From: Patrick Schaaf <netdev@bof.de>
Subject: Re: [PATCH] [BACKPORT] [3.14.56] bnx2x: Don't notify about scratchpad parities
Date: Fri, 06 Nov 2015 18:40:42 +0100
Message-ID: <3468590.Shu13c2CDq@rofl>
References: <2866398.tTChUFNQ37@rofl> <20151106173246.GA6771@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mars.intermailgate.com ([80.242.145.70]:38845 "EHLO
	mars.intermailgate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569AbbKFRkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 12:40:45 -0500
In-Reply-To: <20151106173246.GA6771@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 06 November 2015 09:32:46 Greg KH wrote:
> On Thu, Nov 05, 2015 at 11:18:37AM +0100, Patrick Schaaf wrote:
> > bnx2x: Don't notify about scratchpad parities
> > 
> > This is a (trivial) "backport" of ad6afbe9578d1fa26680faf78c846bd8c00d1d6e
> > to stable kernel 3.14.56.
> 
> This patch isn't in 4.1 either, do you want it there as well?

Personally I'll probably stay on 3.14 until 4.4 comes out, but the patch seems 
to make huge sense generally, given the 1 million in 8 second printk's I 
experienced :)

My 3 servers with the patch applied to 3.14.56 run rock solid so far (but the 
issue I had manifested only after 22 days of uptime, on one of them)

The cited commit from mainline applied nicely with some offset to 3.14.56, so 
I think you could just pull it down to all stable kernels.

best regards
  Patrick

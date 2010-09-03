From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [PATCH] mlx4_core: module param to limit msix vec allocation
Date: Fri, 3 Sep 2010 15:13:03 -0700
Message-ID: <20100903221303.GS2464@sgi.com>
References: <20100826170646.GB27157@sgi.com> <20100826.122407.260097270.davem@davemloft.net> <20100903203044.GN2464@sgi.com> <20100903.144658.149830788.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:37365 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752993Ab0ICWNF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Sep 2010 18:13:05 -0400
Content-Disposition: inline
In-Reply-To: <20100903.144658.149830788.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 03, 2010 at 02:46:58PM -0700, David Miller wrote:
> From: Arthur Kepner <akepner@sgi.com>
> Date: Fri, 3 Sep 2010 13:30:44 -0700
> 
> > I have that running on a (very small) system and it seems to 
> > work OK. Will send out the patch in just a minute.
> 
> Failure vs. non-failure of allocation of a kernel managed physical
> resource can't be determined by a userland process which may or may
> not be running.

But even if there's no user process running, it's no worse 
than what we've got now.

> 
> In fact, if I build all of my drivers built-in and use NFS root which
> will activate and bring up network devices, userland won't even be
> present when the interrupts are requested.

Yep. This only works once the user-level irq balancer is 
available. 

> 
> No, you really can't do it this way, IRQ allocation management has to
> be in the kernel.

Really? I was specifically trying to avoid that, and let the 
policy about interrupt assignment be done in a user process. 

Do you have any specific ideas about how that'd look? 

-- 
Arthur

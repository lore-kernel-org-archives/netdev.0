From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 5/7] forcdeth: increase max_interrupt_work
Date: Sun, 02 Nov 2008 08:30:54 -0500
Message-ID: <490DAB8E.3030006@garzik.org>
References: <200810292122.m9TLMGAI020173@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe.korty@ccur.com, aabdulla@nvidia.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58706 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753260AbYKBNa7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Nov 2008 08:30:59 -0500
In-Reply-To: <200810292122.m9TLMGAI020173@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Joe Korty <joe.korty@ccur.com>
> 
> This eliminates the following often-generated warning from my 64 bit
> Opteron SMP test stand:
> 
> 	eth0: too many iterations (6) in nv_nic_irq
> 
> According to the web, the problem is that the forcedeth driver has a
> too-low value for max_interrupt_work.  Grepping the kernel I see that
> forcedeth has the second lowest value of all ethernet drivers (ie, 6). 
> Most are in the 20-40 range.  So this patch increases this a bit, from 6
> to 15 (at 15 forcedeth becomes the driver with third-lowest
> max_interrupt_work value).
> 
> My test stand, which used to print out the above warnings repetitively
> whenever it was under heavy net load, no longer does so.
> 
> Signed-off-by: Joe Korty <joe.korty@ccur.com>
> Cc: Ayaz Abdulla <aabdulla@nvidia.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/forcedeth.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

applied



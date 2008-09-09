From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch for 2.6.27? 6/6] net: forcedeth: call restore mac addr
	in nv_shutdown path
Date: Tue, 9 Sep 2008 15:25:09 +1000
Message-ID: <20080909052508.GA8157@verge.net.au>
References: <200809052104.m85L4AAm020367@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, yhlu.kernel@gmail.com,
	aabdulla@nvidia.com, jgarzik@redhat.com, ranma+kernel@tdiedrich.de,
	rjw@sisk.pl
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53159 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbYIIFZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 01:25:11 -0400
Content-Disposition: inline
In-Reply-To: <200809052104.m85L4AAm020367@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 05, 2008 at 02:04:10PM -0700, akpm@linux-foundation.org wrote:
> From: Yinghai Lu <yhlu.kernel@gmail.com>
> 
> after
> 
> | commit f735a2a1a4f2a0f5cd823ce323e82675990469e2
> | Author: Tobias Diedrich <ranma+kernel@tdiedrich.de>
> | Date:   Sun May 18 15:02:37 2008 +0200
> |
> |    [netdrvr] forcedeth: setup wake-on-lan before shutting down
> |
> |    When hibernating in 'shutdown' mode, after saving the image the suspend hook
> |    is not called again.
> |    However, if the device is in promiscous mode, wake-on-lan will not work.
> |    This adds a shutdown hook to setup wake-on-lan before the final shutdown.
> |
> |    Signed-off-by: Tobias Diedrich <ranma+kernel@tdiedrich.de>
> |    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
> 
> my servers with nvidia ck804 and mcp55 will reverse mac address with kexec.
> 
> it turns out that we need to restore the mac addr in nv_shutdown().

Does this problem also occur during kdump?

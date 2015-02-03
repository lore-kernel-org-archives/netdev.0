From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net] xen-netback: stop the guest rx thread after a
 fatal error
Date: Mon, 02 Feb 2015 19:39:22 -0800 (PST)
Message-ID: <20150202.193922.1020681915054887138.davem@davemloft.net>
References: <1422896271-26551-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	ian.campbell@citrix.com, wei.liu2@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50308 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958AbbBCDjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 22:39:23 -0500
In-Reply-To: <1422896271-26551-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Mon, 2 Feb 2015 16:57:51 +0000

> After commit e9d8b2c2968499c1f96563e6522c56958d5a1d0d (xen-netback:
> disable rogue vif in kthread context), a fatal (protocol) error would
> leave the guest Rx thread spinning, wasting CPU time.  Commit
> ecf08d2dbb96d5a4b4bcc53a39e8d29cc8fef02e (xen-netback: reintroduce
> guest Rx stall detection) made this even worse by removing a
> cond_resched() from this path.
> 
> Since a fatal error is non-recoverable, just allow the guest Rx thread
> to exit.  This requires taking additional refs to the task so the
> thread exiting early is handled safely.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Reported-by: Julien Grall <julien.grall@linaro.org>
> Tested-by: Julien Grall <julien.grall@linaro.org>

Applied, thank you.

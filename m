From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: forcedeth:
 f55c21fd9a92a444e55ad1ca4e4732d56661bf2e caused wake-on-lan regression
Date: Mon, 16 Feb 2009 00:13:35 -0800 (PST)
Message-ID: <20090216.001335.32409431.davem@davemloft.net>
References: <20090214151200.GA5496@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, rjw@sisk.pl,
	aabdulla@nvidia.com, yhlu.kernel@gmail.com, jeff@garzik.org,
	pmhahn@titan.lahn.de
To: ranma+kernel@tdiedrich.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53978
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751856AbZBPINv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 03:13:51 -0500
In-Reply-To: <20090214151200.GA5496@yamamaya.is-a-geek.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Date: Sat, 14 Feb 2009 16:12:00 +0100

> commit f55c21fd9a92a444e55ad1ca4e4732d56661bf2e, which was
> introduced to fix the regression tracked at
> http://bugzilla.kernel.org/show_bug.cgi?id=11358
> causes the wake-on-lan mac to be reversed in the shutdown path.
> Apparently the forcedeth situation is rather messy in that the mac
> we need to writeback for a subsequent modprobe to work is exactly
> the reverse of what is needed for proper wake-on-lan.
> 
> The following patch explains the situation in the comments and
> makes the call to nv_restore_mac_addr() conditional (only called if
> we are not really going for poweroff).
...
> Signed-off-by: Tobias Diedrich <ranma+kernel@tdiedrich.de>
> Tested-by: Philipp Matthias Hahn <pmhahn@titan.lahn.de>

Applied, thanks a lot.

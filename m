From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] net: fix wrong length of mac address
Date: Fri, 18 Jan 2013 10:14:01 +0300
Message-ID: <20130118071401.GL4584@mwanda>
References: <1358475321-3406-1-git-send-email-kongjianjun@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	devel@linuxdriverproject.org
To: Amos Kong <kongjianjun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44421 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab3ARHOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 02:14:18 -0500
Content-Disposition: inline
In-Reply-To: <1358475321-3406-1-git-send-email-kongjianjun@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You should still CC Haiyang Zhang and KY (as well as netdev).  Use
./scripts/get_maintainer.pl -f drivers/net/hyperv/netvsc_drv.c
to find out where to send patches.

On Fri, Jan 18, 2013 at 10:15:21AM +0800, Amos Kong wrote:
> Replace hardcode 14 with defined ETN_ALEN.
                                     ^
Typo.  It should be ETH_ALEN.

regards,
dan carpenter

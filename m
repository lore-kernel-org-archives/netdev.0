From: David Miller <davem@davemloft.net>
Subject: Re: [patch] qlcnic: info leak in qlcnic_dcb_peer_app_info()
Date: Sat, 24 May 2014 14:01:51 -0400 (EDT)
Message-ID: <20140524.140151.1688847033053939933.davem@davemloft.net>
References: <20140523163721.GA14067@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shahed.shaikh@qlogic.com, sucheta.chakraborty@qlogic.com,
	Dept-HSGLinuxNICDev@qlogic.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbaEXSBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 14:01:54 -0400
In-Reply-To: <20140523163721.GA14067@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 23 May 2014 19:37:21 +0300

> This function is called from dcbnl_build_peer_app().  The "info"
> struct isn't initialized at all so we disclose 2 bytes of uninitialized
> stack data.  We should clear it before passing it to the user.
> 
> Fixes: 48365e485275 ('qlcnic: dcb: Add support for CEE Netlink interface.')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> This is a static analysis patch, and I am not familiar with this code.
> We may want to put some useful information here, to go with the
> app_count.

I've applied this and queued it up for -stable, thanks Dan.

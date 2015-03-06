From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] ax25: remove unneeded NULL test in ax_xmit()
Date: Fri, 06 Mar 2015 01:03:56 -0500 (EST)
Message-ID: <20150306.010356.1391961581224590724.davem@davemloft.net>
References: <20150305174846.GA17072@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, teg@jklm.no, dh.herrmann@gmail.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40488 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755781AbbCFGD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 01:03:58 -0500
In-Reply-To: <20150305174846.GA17072@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 5 Mar 2015 20:48:46 +0300

> We get a static checker warning here on devel kernels:
> 
> 	drivers/net/hamradio/mkiss.c:560 ax_xmit()
> 	warn: variable dereferenced before check 'skb' (see line 532)
> 
> It turns out that the NULL check can be deleted.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.

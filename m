From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: drop write-only stack variable
Date: Sun, 07 Feb 2016 14:07:01 -0500 (EST)
Message-ID: <20160207.140701.1108615326247282670.davem@davemloft.net>
References: <1454433474-8888-1-git-send-email-dh.herrmann@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dh.herrmann@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35600 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbcBGTHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 14:07:04 -0500
In-Reply-To: <1454433474-8888-1-git-send-email-dh.herrmann@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Herrmann <dh.herrmann@gmail.com>
Date: Tue,  2 Feb 2016 18:17:54 +0100

> Remove a write-only stack variable from unix_attach_fds(). This is a
> left-over from the security fix in:
> 
>     commit 712f4aad406bb1ed67f3f98d04c044191f0ff593
>     Author: willy tarreau <w@1wt.eu>
>     Date:   Sun Jan 10 07:54:56 2016 +0100
> 
>         unix: properly account for FDs passed over unix sockets
> 
> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>

Applied, thanks.

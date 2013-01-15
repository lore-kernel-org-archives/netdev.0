From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipip: do not use 'err' variable for setting
 return value
Date: Tue, 15 Jan 2013 03:20:08 -0500 (EST)
Message-ID: <20130115.032008.1473140825117157751.davem@davemloft.net>
References: <1358237650-15953-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sakiwit@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40285 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756371Ab3AOIUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 03:20:11 -0500
In-Reply-To: <1358237650-15953-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>
Date: Tue, 15 Jan 2013 01:14:10 -0700

> It's a bit confusing to set 'err' variable inside and outside of the
> block for the return value of ipip_err(). We don't even need this
> variable, so clean it all up to spare declaration as well as bunch of
> unnecessary initializations and jumps.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>

It makes the non-error path straight line code.

The code as-is is fine, and I'm not applying this patch, sorry.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] iovec: make sure the caller actually wants anything in
 memcpy_fromiovecend
Date: Sat, 02 Aug 2014 15:26:23 -0700 (PDT)
Message-ID: <20140802.152623.2217732437810296124.davem@davemloft.net>
References: <1406862035-27818-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754831AbaHBW0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 18:26:24 -0400
In-Reply-To: <1406862035-27818-1-git-send-email-sasha.levin@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sasha Levin <sasha.levin@oracle.com>
Date: Thu, 31 Jul 2014 23:00:35 -0400

> Check for cases when the caller requests 0 bytes instead of running off
> and dereferencing potentially invalid iovecs.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied, thanks.

BTW, if you look at the function above this one (memcpy_toiovecend) it avoids
this issue by encompassing all of the logic in a top-level loop which terminates
when len <= 0.

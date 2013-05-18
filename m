From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netback: remove dead code
Date: Fri, 17 May 2013 18:23:26 -0700 (PDT)
Message-ID: <20130517.182326.453843102438452044.davem@davemloft.net>
References: <1368782668-23952-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46970 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803Ab3ERBX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 21:23:27 -0400
In-Reply-To: <1368782668-23952-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Fri, 17 May 2013 10:24:28 +0100

> The array mmap_pages is never touched in the initialization function. This is
> remnant of mapping mechanism, which does not exist upstream. In current
> upstream code this array only tracks usage of pages inside netback. Those
> pages are allocated when contructing a SKB and passed directly to network
> subsystem.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: fix a potential oops
Date: Fri, 29 Aug 2014 20:22:59 -0700 (PDT)
Message-ID: <20140829.202259.1402624640108814825.davem@davemloft.net>
References: <1409191361-28179-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52763 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888AbaH3DXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 23:23:00 -0400
In-Reply-To: <1409191361-28179-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Thu, 28 Aug 2014 10:02:41 +0800

> Commit 6c9808ce09f7 ("tipc: remove port_lock") accidentally involves
> a potential bug: when tipc socket instance(tsk) is not got with given
> reference number in tipc_sk_get(), tsk is set to NULL. Subsequently
> we jump to exit label where to decrease socket reference counter
> pointed by tsk pointer in tipc_sk_put(). However, As now tsk is NULL,
> oops may happen because of touching a NULL pointer.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Acked-by: Erik Hugne <erik.hugne@ericsson.com>
> Acked-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks.

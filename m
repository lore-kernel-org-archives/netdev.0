From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] ipv6: Fix problem with expired dst cache
Date: Mon, 05 Mar 2012 00:05:58 -0500 (EST)
Message-ID: <20120305.000558.923755086046890012.davem@davemloft.net>
References: <1330064404-24763-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1330919628-11837-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047Ab2CEFGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 00:06:05 -0500
In-Reply-To: <1330919628-11837-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Mon, 5 Mar 2012 11:53:48 +0800

> +		/* point to where the dst_entry copied from */
> +		void			*from;

So instead of using a real type here, your just going to cast
this thing to and from "struct dst_entry *" a thousand times?

That's terrible, there is zero value from using a void pointer
here, it just makes the code look ugly.

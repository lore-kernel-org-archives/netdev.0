From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_gre: release cached dst on tunnel removal
Date: Tue, 25 Aug 2015 14:34:01 -0700 (PDT)
Message-ID: <20150825.143401.1316801578363855926.davem@davemloft.net>
References: <1440512434-4488-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, huaibin.wang@6wind.com, xeb@mail.ru
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755749AbbHYVeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 17:34:02 -0400
In-Reply-To: <1440512434-4488-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 25 Aug 2015 16:20:34 +0200

> From: huaibin Wang <huaibin.wang@6wind.com>
> 
> When a tunnel is deleted, the cached dst entry should be released.
> 
> This problem may prevent the removal of a netns (seen with a x-netns IPv6
> gre tunnel):
>   unregister_netdevice: waiting for lo to become free. Usage count = 3
> 
> CC: Dmitry Kozlov <xeb@mail.ru>
> Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
> Signed-off-by: huaibin Wang <huaibin.wang@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied and queued up for -stable, thanks.

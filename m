From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: dev: deinit list in unregister_netdevice_many
Date: Tue, 26 Feb 2013 23:12:26 -0800
Message-ID: <1361949146.11403.21.camel@edumazet-glaptop>
References: <1361948391-4906-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:44249 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196Ab3B0HM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 02:12:29 -0500
Received: by mail-pb0-f53.google.com with SMTP id un1so188986pbc.40
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 23:12:29 -0800 (PST)
In-Reply-To: <1361948391-4906-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-27 at 14:59 +0800, Gao feng wrote:
> commit ceaaec98ad99859ac90ac6863ad0a6cd075d8e0e
> "net: deinit automatic LIST_HEAD"  has already done
> part of the deinit list jobs.
> 
> This patch push list_del into unregister_netdevice_many
> to make sure the unreg_list of netdevice object has valid
> pointer always.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---

I totally Nack this patch.

1) net-next is not open.

2) We spent enough time chasing bugs, I don't want to reintroduce new
ones.

And this patch introduce nice bugs. No thank you.

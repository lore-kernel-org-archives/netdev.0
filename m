From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] bonding: use rtnl_deref in
 bond_change_rx_flags()
Date: Wed, 16 Jul 2014 23:35:02 -0700 (PDT)
Message-ID: <20140716.233502.8768823657977481.davem@davemloft.net>
References: <1405528321-19877-1-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, andy@greyhouse.net,
	edumazet@google.com
To: vfalico@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57804 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668AbaGQGfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 02:35:02 -0400
In-Reply-To: <1405528321-19877-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@gmail.com>
Date: Wed, 16 Jul 2014 18:32:01 +0200

> As it's always called with RTNL held, via dev_set_allmulti/promiscuity.
> Also, remove the wrong comment.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
> ---
> 
> Notes:
>     v1->v2:
>     also remove the misleading comment

Eric if this is fine with you now, please review and ack, thanks.

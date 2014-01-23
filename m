From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ip_tunnel: clear IPCB in ip_tunnel_xmit() in case
 dst_link_failure() is called
Date: Thu, 23 Jan 2014 13:28:53 -0800 (PST)
Message-ID: <20140123.132853.359079312909728804.davem@davemloft.net>
References: <CALnjE+qFPoK_0EnZ_TWe1sx4s166iSjAH_+1r2uENeS4aRBckQ@mail.gmail.com>
	<20140122.212445.2236898585371895394.davem@davemloft.net>
	<52E0AFF9.6050803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, daniel.petre@rcs-rds.ro, edumazet@google.com,
	netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752139AbaAWV2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 16:28:54 -0500
In-Reply-To: <52E0AFF9.6050803@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Thu, 23 Jan 2014 14:00:25 +0800

> 
> commit a622260254ee48("ip_tunnel: fix kernel panic with icmp_dest_unreach")
> clear IPCB in ip_tunnel_xmit()  , or else skb->cb[] may contain garbage from
> GSO segmentation layer.
> 
> But commit 0e6fbc5b6c621("ip_tunnels: extend iptunnel_xmit()") refactor codes,
> and it clear IPCB behind the dst_link_failure().
> 
> So clear IPCB in ip_tunnel_xmit() just like commti a622260254ee48("ip_tunnel:
> fix kernel panic with icmp_dest_unreach").
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied and queued up for -stable, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [VLAN] sparse warning fix
Date: Mon, 21 Jan 2008 17:28:08 -0800 (PST)
Message-ID: <20080121.172808.67126688.davem@davemloft.net>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
	<20080121.003406.162149599.davem@davemloft.net>
	<20080121094849.1e2ccee1@deepthought>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42327
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752864AbYAVB2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 20:28:02 -0500
In-Reply-To: <20080121094849.1e2ccee1@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 21 Jan 2008 09:48:49 -0800

> Minor sparse warning fix.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.

> @@ -220,6 +220,7 @@ static inline int is_vlan_dev(struct net
>  
>  /* start read of /proc/net/vlan/config */
>  static void *vlan_seq_start(struct seq_file *seq, loff_t *pos)
> + 	__acquires(dev_base_lock)
   ^

Space before tab.

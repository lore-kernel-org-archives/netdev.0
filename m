From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v5 01/16] net: qdisc: use rcu prefix and
 silence sparse warnings
Date: Fri, 12 Sep 2014 09:36:50 -0700
Message-ID: <1410539810.7106.96.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140912162748.19588.39677.stgit@nitbit.x32>
	 <20140912162851.19588.77481.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:61259 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbaILQgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 12:36:52 -0400
Received: by mail-pa0-f44.google.com with SMTP id kx10so1650026pab.31
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 09:36:51 -0700 (PDT)
In-Reply-To: <20140912162851.19588.77481.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-12 at 09:28 -0700, John Fastabend wrote:
> Add __rcu notation to qdisc handling by doing this we can make
> smatch output more legible. And anyways some of the cases should
> be using rcu_dereference() see qdisc_all_tx_empty(),
> qdisc_tx_chainging(), and so on.
> 
> Also *wake_queue() API is commonly called from driver timer routines
> without rcu lock or rtnl lock. So I added rcu_read_lock() blocks
> around netif_wake_subqueue and netif_tx_wake_queue.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

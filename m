From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] neigh: make strucrt neigh_table::entry_size
 unsigned int
Date: Mon, 25 Sep 2017 20:36:52 -0700 (PDT)
Message-ID: <20170925.203652.2254718838332266992.davem@davemloft.net>
References: <20170923200106.GA24928@avx2>
        <20170923200304.GB24928@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ganeshgr@chelsio.com
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40722 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933685AbdIZDgw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 23:36:52 -0400
In-Reply-To: <20170923200304.GB24928@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sat, 23 Sep 2017 23:03:04 +0300

> Key length can't be negative.
> 
> Leave comparisons against nla_len() signed just in case truncated attribute
> can sneak in there.
> 
> Space savings:
> 
> 	add/remove: 0/0 grow/shrink: 0/7 up/down: 0/-7 (-7)
> 	function                                     old     new   delta
> 	pneigh_delete                                273     272      -1
> 	mlx5e_rep_netevent_event                    1415    1414      -1
> 	mlx5e_create_encap_header_ipv6              1194    1193      -1
> 	mlx5e_create_encap_header_ipv4              1071    1070      -1
> 	cxgb4_l2t_get                               1104    1103      -1
> 	__pneigh_lookup                               69      68      -1
> 	__neigh_create                              2452    2451      -1
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.

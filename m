From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] fix IP-over-ATM and ARP interaction.
Date: Sun, 07 May 2006 01:31:35 +0900 (JST)
Message-ID: <20060507.013135.95236394.yoshfuji@linux-ipv6.org>
References: <E1FcPPN-0004xi-00@thekelleys.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43525 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1750944AbWEFQbZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 12:31:25 -0400
To: simon@thekelleys.org.uk
In-Reply-To: <E1FcPPN-0004xi-00@thekelleys.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <E1FcPPN-0004xi-00@thekelleys.org.uk> (at Sat, 06 May 2006 17:13:29 +0100), Simon Kelley <simon@thekelleys.org.uk> says:

> +void neigh_table_init(struct neigh_table *tbl)
> +{
> +  struct neigh_table *tmp;
> +
> +  neigh_table_init_no_netlink(tbl);
> +  write_lock(&neigh_tbl_lock);
> +  for (tmp = neigh_tables; tmp; tmp = tmp->next)
> +        BUG_ON(tmp->family == tbl->family);
> +  tbl->next	= neigh_tables;
> +  neigh_tables	= tbl;
> +  write_unlock(&neigh_tbl_lock);
>  }
>  
>  int neigh_table_clear(struct neigh_table *tbl)

Please fix the coding style; use tab for indent, please.

--yoshfuji

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ibm: ibmveth: constify dev_pm_ops structures.
Date: Thu, 29 Jun 2017 15:49:37 -0400 (EDT)
Message-ID: <20170629.154937.1428574116488487036.davem@davemloft.net>
References: <24303710c4e099faa0ca7d9d92a71e53d6b66bcc.1498714986.git.arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au,
        tlfalcon@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45192 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752475AbdF2Ttk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 15:49:40 -0400
In-Reply-To: <24303710c4e099faa0ca7d9d92a71e53d6b66bcc.1498714986.git.arvind.yadav.cs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Thu, 29 Jun 2017 11:14:50 +0530

> dev_pm_ops are not supposed to change at runtime. All functions
> working with dev_pm_ops provided by <linux/device.h> work with const
> dev_pm_ops. So mark the non-const structs as const.
> 
> File size before:
>    text	   data	    bss	    dec	    hex	filename
>   15426	   1256	      0	  16682	   412a	drivers/net/ethernet/ibm/ibmveth.o
> 
> File size After adding 'const':
>    text	   data	    bss	    dec	    hex	filename
>   15618	   1064	      0	  16682	   412a	drivers/net/ethernet/ibm/ibmveth.o
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

Applied.

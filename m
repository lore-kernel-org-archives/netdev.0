From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: fix potential sk_wmem_alloc imbalance
Date: Mon, 09 Jul 2012 15:28:27 -0700 (PDT)
Message-ID: <20120709.152827.1547447409352502785.davem@davemloft.net>
References: <1341524713.3265.41.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, manfred.rudigier@omicron.at,
	claudiu.manoil@freescale.com, b06378@freescale.com,
	paul.gortmaker@windriver.com, afleming@freescale.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246Ab2GIW22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 18:28:28 -0400
In-Reply-To: <1341524713.3265.41.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Jul 2012 23:45:13 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> commit db83d136d7f753 (gianfar: Fix missing sock reference when
> processing TX time stamps) added a potential sk_wmem_alloc imbalance
> 
> If the new skb has a different truesize than old one, we can get a
> negative sk_wmem_alloc once new skb is orphaned at TX completion.
> 
> Now we no longer early orphan skbs in dev_hard_start_xmit(), this
> probably can lead to fatal bugs.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Manfred Rudigier <manfred.rudigier@omicron.at>
> Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
> Cc: Jiajun Wu <b06378@freescale.com>
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
> Cc: Andy Fleming <afleming@freescale.com>

Now that this has been tested by Paul, I've applied it.

Thanks.

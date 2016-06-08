From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 2/2] net: vrf: Add l3mdev rules on first
 device create
Date: Wed, 08 Jun 2016 00:24:35 -0700 (PDT)
Message-ID: <20160608.002435.1465827803733679229.davem@davemloft.net>
References: <[PATCH_net-next_v4_0/2]_net:_vrf:_Improve_use_of_FIB_rules>
	<1465270552-30925-1-git-send-email-dsa@cumulusnetworks.com>
	<1465270552-30925-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753369AbcFHHYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 03:24:39 -0400
In-Reply-To: <1465270552-30925-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon,  6 Jun 2016 20:35:52 -0700

> @@ -42,6 +43,9 @@
>  #define DRV_NAME	"vrf"
>  #define DRV_VERSION	"1.0"
>  
> +static bool add_fib_rules = true;
> +static u32 rule_pref = 1000; /* default preference for FIB rules */
> +
>  struct net_vrf {

Haste, makes waste...

"static const u32 rule_pref" or use a CPP define.

Thanks.

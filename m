From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -net] net/ethernet: tundra: fix dump_eth_one warning in
 tsi108_eth
Date: Mon, 08 Aug 2016 13:08:40 -0700 (PDT)
Message-ID: <20160808.130840.276329308290273424.davem@davemloft.net>
References: <20160804200758.29835-1-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34173 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbcHHUIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 16:08:46 -0400
Received: by mail-pf0-f195.google.com with SMTP id g202so25610914pfb.1
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 13:08:45 -0700 (PDT)
In-Reply-To: <20160804200758.29835-1-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 4 Aug 2016 16:07:58 -0400

> The call site for this function appears as:
> 
>   #ifdef DEBUG
>         data->msg_enable = DEBUG;
>         dump_eth_one(dev);
>   #endif
> 
> ...leading to the following warning for !DEBUG builds:
> 
> drivers/net/ethernet/tundra/tsi108_eth.c:169:13: warning: 'dump_eth_one' defined but not used [-Wunused-function]
>  static void dump_eth_one(struct net_device *dev)
>              ^
> 
> ...when using the arch/powerpc/configs/mpc7448_hpc2_defconfig
> 
> Put the function definition under the same #ifdef as the call site
> to avoid the warning.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks.

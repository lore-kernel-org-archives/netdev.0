From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/8] net/wan/fsl_ucc_hdlc: fix unitialized
 variable warnings
Date: Thu, 18 May 2017 10:29:16 -0400 (EDT)
Message-ID: <20170518.102916.466850819247317599.davem@davemloft.net>
References: <20170517152439.8817-1-holger.brunck@keymile.com>
        <20170517152439.8817-2-holger.brunck@keymile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, qiang.zhao@nxp.com
To: holger.brunck@keymile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43414 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932189AbdERO31 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:29:27 -0400
In-Reply-To: <20170517152439.8817-2-holger.brunck@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Brunck <holger.brunck@keymile.com>
Date: Wed, 17 May 2017 17:24:33 +0200

> This fixes the following compiler warnings:
> drivers/net/wan/fsl_ucc_hdlc.c: In function 'ucc_hdlc_poll':
> warning: 'skb' may be used uninitialized in this function
> [-Wmaybe-uninitialized]
>   skb->mac_header = skb->data - skb->head;
> 
> and
> 
> drivers/net/wan/fsl_ucc_hdlc.c: In function 'ucc_hdlc_probe':
> drivers/net/wan/fsl_ucc_hdlc.c:1127:3: warning: 'utdm' may be used
> uninitialized in this function [-Wmaybe-uninitialized]
>    kfree(utdm);
> 
> Signed-off-by: Holger Brunck <holger.brunck@keymile.com>

Applied.

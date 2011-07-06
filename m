From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] veth: Kill unused code label and code block.
Date: Wed, 6 Jul 2011 08:16:35 +0000 (UTC)
Message-ID: <iv15l2$dvl$1@dough.gmane.org>
References: <20110705.234930.2282002049899864045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:60533 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751622Ab1GFIQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2011 04:16:47 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1QeNHq-0006Td-Ss
	for netdev@vger.kernel.org; Wed, 06 Jul 2011 10:16:46 +0200
Received: from 60.160.69.5 ([60.160.69.5])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2011 10:16:46 +0200
Received: from xiyou.wangcong by 60.160.69.5 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2011 10:16:46 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 05 Jul 2011 23:49:30 -0700, David Miller wrote:

>  
> -tx_drop:
> -	kfree_skb(skb);
> -	u64_stats_update_begin(&stats->syncp); -	stats->tx_dropped++;
> -	u64_stats_update_end(&stats->syncp); -	return NETDEV_TX_OK;
> -

Ahh, yeah, we have removed the goto tx_drop...

Reviewed-by: WANG Cong <xiyou.wangcong@gmail.com>


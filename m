From: David Miller <davem@davemloft.net>
Subject: Re: [net-next,v2] ip_gre: check packet length and mtu correctly in
 erspan tx
Date: Sat, 07 Oct 2017 23:17:34 +0100 (WEST)
Message-ID: <20171007.231734.606486987105293487.davem@davemloft.net>
References: <1507230432-56495-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lucien.xin@gmail.com,
        David.Laight@aculab.com
To: u9012063@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42932 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752997AbdJGWRq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 18:17:46 -0400
In-Reply-To: <1507230432-56495-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Tu <u9012063@gmail.com>
Date: Thu,  5 Oct 2017 12:07:12 -0700

> Similarly to early patch for erspan_xmit(), the ARPHDR_ETHER device
> is the length of the whole ether packet.  So skb->len should subtract
> the dev->hard_header_len.
> 
> Fixes: 1a66a836da63 ("gre: add collect_md mode to ERSPAN tunnel")
> Fixes: 84e54fe0a5ea ("gre: introduce native tunnel support for ERSPAN")
> Signed-off-by: William Tu <u9012063@gmail.com>

Applied.

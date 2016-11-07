From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Update raw socket bind to consider l3
 domain
Date: Mon, 07 Nov 2016 13:15:02 -0500 (EST)
Message-ID: <20161107.131502.346849142364346073.davem@davemloft.net>
References: <1478190300-14094-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39134 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932526AbcKGSPD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 13:15:03 -0500
In-Reply-To: <1478190300-14094-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu,  3 Nov 2016 09:25:00 -0700

> Binding a raw socket to a local address fails if the socket is bound
> to an L3 domain:
> 
>     $ vrf-test  -s -l 10.100.1.2 -R -I red
>     error binding socket: 99: Cannot assign requested address
> 
> Update raw_bind to look consider if sk_bound_dev_if is bound to an L3
> domain and use inet_addr_type_table to lookup the address.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.

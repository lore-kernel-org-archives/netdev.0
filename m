From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: ulp: avoid module refcnt leak in tcp_set_ulp
Date: Mon, 14 Aug 2017 22:17:37 -0700 (PDT)
Message-ID: <20170814.221737.507862199447270473.davem@davemloft.net>
References: <776711b75a664f4a61da8d32eab15d3e794cabe7.1502725540.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davejwatson@fb.com, borisp@mellanox.com,
        tom@quantonium.net, hannes@stressinduktion.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50472 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751605AbdHOFRi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 01:17:38 -0400
In-Reply-To: <776711b75a664f4a61da8d32eab15d3e794cabe7.1502725540.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Mon, 14 Aug 2017 18:04:24 +0200

> __tcp_ulp_find_autoload returns tcp_ulp_ops after taking a reference on
> the module. Then, if ->init fails, tcp_set_ulp propagates the error but
> nothing releases that reference.
> 
> Fixes: 734942cc4ea6 ("tcp: ULP infrastructure")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied, thanks.

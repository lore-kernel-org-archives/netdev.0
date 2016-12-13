From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netlink: revert broken, broken "2-clause
 nla_ok()"
Date: Tue, 13 Dec 2016 14:55:06 -0500 (EST)
Message-ID: <20161213.145506.640354612749299686.davem@davemloft.net>
References: <CACVxJT9Qc=vNexx4ooQVFo=SrGs4-oHeZrnL18vbiS+o0F_N1A@mail.gmail.com>
        <1480950553.31788.40.camel@sipsolutions.net>
        <20161213193015.GA10610@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35954 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753665AbcLMUEu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 15:04:50 -0500
In-Reply-To: <20161213193015.GA10610@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 13 Dec 2016 22:30:15 +0300

> Commit 4f7df337fe79bba1e4c2d525525d63b5ba186bbd
> "netlink: 2-clause nla_ok()" is BROKEN.
> 
> First clause tests if "->nla_len" could even be accessed at all,
> it can not possibly be omitted.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks.

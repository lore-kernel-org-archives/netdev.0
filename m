From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 5/5] xfrm: eradicate size_t
Date: Mon, 25 Sep 2017 13:46:26 +0200
Message-ID: <20170925114625.GP3149@secunet.com>
References: <20170921204543.GB13550@avx2>
 <20170921204853.GF13550@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:42982 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752333AbdIYLq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 25 Sep 2017 07:46:29 -0400
Content-Disposition: inline
In-Reply-To: <20170921204853.GF13550@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 21, 2017 at 11:48:54PM +0300, Alexey Dobriyan wrote:
> All netlink message sizes are a) unsigned, b) can't be >= 4GB in size
> because netlink doesn't support >= 64KB messages in the first place.
> 
> All those size_t across the code are a scam especially across networking
> which likes to work with small numbers like 1500 or 65536.
> 
> Propagate unsignedness and flip some "int" to "unsigned int" as well.
> 
> This is preparation to switching nlmsg_new() to "unsigned int".
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

All applied to ipsec-next, thanks Alexey!

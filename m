From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: use "unsigned int" in __xfrm6_pref_hash()
Date: Mon, 27 Mar 2017 12:36:07 +0200
Message-ID: <20170327103607.GG23004@secunet.com>
References: <20170323225309.GC31372@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:39950 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752301AbdC0KhZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 06:37:25 -0400
Content-Disposition: inline
In-Reply-To: <20170323225309.GC31372@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 24, 2017 at 01:53:09AM +0300, Alexey Dobriyan wrote:
> x86_64 is zero-extending arch so "unsigned int" is preferred over "int"
> for address calculations.
> 
> Space savings:
> 
> 	add/remove: 0/0 grow/shrink: 0/3 up/down: 0/-58 (-58)
> 	function                                     old     new   delta
> 	xfrm_hash_resize                            2752    2743      -9
> 	policy_hash_bysel                            985     973     -12
> 	policy_hash_direct                          1036     999     -37
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied to ipsec-next, thanks!

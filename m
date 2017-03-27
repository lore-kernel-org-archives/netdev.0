From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: use "unsigned int" in addr_match()
Date: Mon, 27 Mar 2017 12:36:30 +0200
Message-ID: <20170327103630.GH23004@secunet.com>
References: <20170323230750.GD31372@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:39972 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752246AbdC0Kie (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 06:38:34 -0400
Content-Disposition: inline
In-Reply-To: <20170323230750.GD31372@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 24, 2017 at 02:07:50AM +0300, Alexey Dobriyan wrote:
> x86_64 is zero-extending arch so "unsigned int" is preferred over "int"
> for address calculations and extending to size_t.
> 
> Space savings:
> 
> 	add/remove: 0/0 grow/shrink: 0/2 up/down: 0/-24 (-24)
> 	function                                     old     new   delta
> 	xfrm_state_walk                              708     696     -12
> 	xfrm_selector_match                          918     906     -12
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied to ipsec-next, thanks!

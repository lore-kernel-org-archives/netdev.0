From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make in_aton() 32-bit internally
Date: Fri, 24 Mar 2017 13:27:41 -0700 (PDT)
Message-ID: <20170324.132741.143940813957492042.davem@davemloft.net>
References: <20170323215826.GA31372@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44160 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756168AbdCXU1m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 16:27:42 -0400
In-Reply-To: <20170323215826.GA31372@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 24 Mar 2017 00:58:26 +0300

> Converting IPv4 address doesn't need 64-bit arithmetic.
> 
> Space savings: 10 bytes!
> 
> 	add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-10 (-10)
> 	function                          old     new   delta
> 	in_aton                            96      86     -10
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied to net-next, thanks.

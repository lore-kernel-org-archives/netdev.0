From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arp: make arp_hdr_len() return unsigned int
Date: Thu, 28 Sep 2017 10:29:49 -0700 (PDT)
Message-ID: <20170928.102949.1161858983032608331.davem@davemloft.net>
References: <20170926201228.GA31899@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50032 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752192AbdI1R3u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 13:29:50 -0400
In-Reply-To: <20170926201228.GA31899@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 26 Sep 2017 23:12:28 +0300

> Negative ARP header length are not a thing.
> 
> Constify arguments while I'm at it.
> 
> Space savings:
> 
> 	add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-3 (-3)
> 	function                        old     new   delta
> 	arpt_do_table                  1163    1160      -3
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.

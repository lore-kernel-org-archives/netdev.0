From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] soreuseport: use "unsigned int" in __reuseport_alloc()
Date: Mon, 03 Apr 2017 19:06:58 -0700 (PDT)
Message-ID: <20170403.190658.34782983666043702.davem@davemloft.net>
References: <20170402221823.GA4709@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kraig@google.com
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53208 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752415AbdDDCHA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 22:07:00 -0400
In-Reply-To: <20170402221823.GA4709@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 3 Apr 2017 01:18:23 +0300

> Number of sockets is limited by 16-bit, so 64-bit allocation will never
> happen.
> 
> 16-bit ops are the worst code density-wise on x86_64 because of
> additional prefix (66).
> 
> Space savings:
> 
> 	add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-3 (-3)
> 	function                                     old     new   delta
> 	reuseport_add_sock                           539     536      -3
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.

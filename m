From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Fix nexthop exception hash computation.
Date: Tue, 17 Jul 2012 22:33:21 +0200
Message-ID: <1342557201.2626.1084.camel@edumazet-glaptop>
References: <20120717.132350.1202093690532763592.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:42269 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858Ab2GQUdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 16:33:25 -0400
Received: by yenl2 with SMTP id l2so863733yen.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 13:33:24 -0700 (PDT)
In-Reply-To: <20120717.132350.1202093690532763592.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-17 at 13:23 -0700, David Miller wrote:
> Need to mask it with (FNHE_HASH_SIZE - 1).
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

OK, I have a small patch too, sending in a minute.

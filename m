From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Fix input route performance regression.
Date: Fri, 27 Jul 2012 00:16:29 +0200
Message-ID: <1343340989.2626.12087.camel@edumazet-glaptop>
References: <20120726.141438.1996323620706359167.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:57351 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114Ab2GZWQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 18:16:34 -0400
Received: by wibhm11 with SMTP id hm11so6862965wib.1
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 15:16:33 -0700 (PDT)
In-Reply-To: <20120726.141438.1996323620706359167.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-26 at 14:14 -0700, David Miller wrote:
> With the routing cache removal we lost the "noref" code paths on
> input, and this can kill some routing workloads.
> 
> Reinstate the noref path when we hit a cached route in the FIB
> nexthops.
> 
> With help from Eric Dumazet.
> 
> Reported-by: Alexander Duyck <alexander.duyck@gmail.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks !

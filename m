From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [v2 PATCH 2/4] tcp: Move code related to head frag in
 tcp_try_coalesce
Date: Thu, 03 May 2012 09:50:56 +0200
Message-ID: <1336031456.3503.24.camel@edumazet-glaptop>
References: <20120503071141.13636.37564.stgit@gitlad.jf.intel.com>
	 <20120503071904.13636.61130.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:36710 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738Ab2ECHu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 03:50:59 -0400
Received: by eaaq12 with SMTP id q12so405086eaa.19
        for <netdev@vger.kernel.org>; Thu, 03 May 2012 00:50:58 -0700 (PDT)
In-Reply-To: <20120503071904.13636.61130.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-03 at 00:19 -0700, Alexander Duyck wrote:
> This change reorders the code related to the use of an skb->head_frag so it
> is placed before we check the rest of the frags.  This allows the code to
> read more linearly instead of like some sort of loop.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  net/ipv4/tcp_input.c |   42 +++++++++++++++++++++++++-----------------
>  1 files changed, 25 insertions(+), 17 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

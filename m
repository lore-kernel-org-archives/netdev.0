From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] skb: Add inline helper for getting the skb end
 offset from head
Date: Sat, 05 May 2012 07:39:21 +0200
Message-ID: <1336196361.3752.485.camel@edumazet-glaptop>
References: <20120505001059.21292.31647.stgit@gitlad.jf.intel.com>
	 <20120505002656.21292.89799.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:64266 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150Ab2EEFj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2012 01:39:26 -0400
Received: by wgbds11 with SMTP id ds11so2330wgb.1
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 22:39:25 -0700 (PDT)
In-Reply-To: <20120505002656.21292.89799.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-04 at 17:26 -0700, Alexander Duyck wrote:
> With the recent changes for how we compute the skb truesize it occurs to me
> we are probably going to have a lot of calls to skb_end_pointer -
> skb->head.  Instead of running all over the place doing that it would make
> more sense to just make it a separate inline skb_end_offset(skb) that way
> we can return the correct value without having gcc having to do all the
> optimization to cancel out skb->head - skb->head.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
> 
>  drivers/atm/ambassador.c             |    2 +-
>  drivers/atm/idt77252.c               |    2 +-
>  drivers/net/wimax/i2400m/usb-rx.c    |    2 +-
>  drivers/staging/octeon/ethernet-tx.c |    2 +-
>  include/linux/skbuff.h               |   12 +++++++++++-
>  net/core/skbuff.c                    |   12 ++++++------
>  6 files changed, 21 insertions(+), 11 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

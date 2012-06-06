From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] e1000e: Change wthresh to 1 to avoid possible Tx
 stalls.
Date: Wed, 06 Jun 2012 10:50:54 +0200
Message-ID: <1338972654.2760.3955.camel@edumazet-glaptop>
References: <20120606174355.823e9aa7.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, davem@davemloft.net,
	denys@visp.net.lb, therbert@google.com, netdev@vger.kernel.org
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:64555 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199Ab2FFIu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 04:50:58 -0400
Received: by eeit10 with SMTP id t10so2213600eei.19
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 01:50:57 -0700 (PDT)
In-Reply-To: <20120606174355.823e9aa7.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-06 at 17:43 +0900, Hiroaki SHIMODA wrote:
> Denys Fedoryshchenko reported Tx stalls on e1000e with BQL enabled.
> 
> e1000e has WTHRESH which determines when Tx descripters are written
> back and successive Tx interrupts are generated, and setting WTHRESH
> to 5 gives efficient bus utilization but this cause possible Tx stalls,
> especially on BQL enabled system.
> 
> To avoid possible Tx stalls, change WTHRESH to 1.
> 
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Tested-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> ---
>  drivers/net/ethernet/intel/e1000e/e1000.h  |    6 +++---
>  drivers/net/ethernet/intel/e1000e/netdev.c |    2 +-
>  2 files changed, 4 insertions(+), 4 deletions(-)

Thanks a lot !

Acked-by: Eric Dumazet <edumazet@google.com>

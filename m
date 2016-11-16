From: Bert Kenward <bkenward@solarflare.com>
Subject: Re: [PATCH net-next] sfc: remove napi_hash_del() call
Date: Wed, 16 Nov 2016 14:15:05 +0000
Message-ID: <346f2de7-ef32-e60f-fe1d-d2eae0071636@solarflare.com>
References: <1479304907.8455.171.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Edward Cree <ecree@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:30213 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753187AbcKPO1L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:27:11 -0500
In-Reply-To: <1479304907.8455.171.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/11/16 14:01, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Calling napi_hash_del() after netif_napi_del() is pointless.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Edward Cree <ecree@solarflare.com>
> Cc: Bert Kenward <bkenward@solarflare.com>
> ---
>  drivers/net/ethernet/sfc/efx.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)

Acked-by: Bert Kenward <bkenward@solarflare.com>

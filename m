From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 1/2] bnx2x: add support for ndo_ll_poll
Date: Wed, 19 Jun 2013 01:18:33 -0700
Message-ID: <1371629913.3252.269.camel@edumazet-glaptop>
References: <1371594965-12546-1-git-send-email-dmitry@broadcom.com>
	 <1371594965-12546-2-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:57178 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756629Ab3FSISj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 04:18:39 -0400
Received: by mail-ee0-f45.google.com with SMTP id c1so3031595eek.32
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 01:18:38 -0700 (PDT)
In-Reply-To: <1371594965-12546-2-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-19 at 01:36 +0300, Dmitry Kravkov wrote:
> Adds ndo_ll_poll method and locking for FPs between LL and the napi.
> 
> When receiving a packet we use skb_mark_ll to record the napi it came from.
> Add each napi to the napi_hash right after netif_napi_add().
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>

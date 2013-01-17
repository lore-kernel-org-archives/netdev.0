From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: fix GRO parameters
Date: Thu, 17 Jan 2013 06:33:01 -0800
Message-ID: <1358433181.29723.16.camel@edumazet-glaptop>
References: <1358429181-3348-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com,
	ariele@broadcom.com
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:48311 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094Ab3AQOdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 09:33:05 -0500
Received: by mail-pa0-f53.google.com with SMTP id hz1so1502458pad.40
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 06:33:04 -0800 (PST)
In-Reply-To: <1358429181-3348-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-17 at 15:26 +0200, Yuval Mintz wrote:
> bnx2x does an internal GRO pass but doesn't provide gso_segs, thus
> breaking qdisc_pkt_len_init() in case ingress qdisc is used.
> 
> We store gso_segs in NAPI_GRO_CB(skb)->count, where tcp_gro_complete()
> expects to find the number of aggregated segments.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> ---
> This is Eric Dumazet's patch with slight semantic modifications.
> Eric - Do you want to put your ack or signoff on this patch?
> 

Sure, thanks !

Signed-off-by: Eric Dumazet <edumazet@google.com>

> Dave - Please apply this to 'net-next' afterwards.
> 
> Thanks,
> Yuval Mintz

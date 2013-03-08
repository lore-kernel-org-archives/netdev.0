From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bridging: fix rx_handlers return code
Date: Fri, 08 Mar 2013 09:14:10 -0800
Message-ID: <1362762850.15793.245.camel@edumazet-glaptop>
References: <1362762218-5198-1-git-send-email-B43982@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Cristian Bercaru <B43982@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f171.google.com ([209.85.210.171]:64073 "EHLO
	mail-ia0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759811Ab3CHRON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 12:14:13 -0500
Received: by mail-ia0-f171.google.com with SMTP id z13so1720088iaz.16
        for <netdev@vger.kernel.org>; Fri, 08 Mar 2013 09:14:13 -0800 (PST)
In-Reply-To: <1362762218-5198-1-git-send-email-B43982@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-08 at 19:03 +0200, Cristian Bercaru wrote:
> The frames for which rx_handlers return RX_HANDLER_CONSUMED are no longer
> counted as dropped. They are counted as successfully received by
> 'netif_receive_skb'.
> 
> This allows network interface drivers to correctly update their RX-OK and
> RX-DRP counters based on the result of 'netif_receive_skb'.
> 
> Signed-off-by: Cristian Bercaru <B43982@freescale.com>
> ---

Signed-off-by: Eric Dumazet <edumazet@google.com>

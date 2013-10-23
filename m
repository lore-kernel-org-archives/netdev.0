From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: initialize hashrnd in flow_dissector
 with net_get_random_once
Date: Wed, 23 Oct 2013 06:58:34 -0700
Message-ID: <1382536714.7572.18.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131023111219.GA31531@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:48877 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054Ab3JWN6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 09:58:38 -0400
Received: by mail-ee0-f45.google.com with SMTP id c50so523189eek.32
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 06:58:37 -0700 (PDT)
In-Reply-To: <20131023111219.GA31531@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-23 at 13:12 +0200, Hannes Frederic Sowa wrote:
> We also can defer the initialization of hashrnd in flow_dissector
> to its first use. Since net_get_random_once is irqsave now we don't
> have to audit the call paths if one of this functions get called by an
> interrupt handler.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

This really works well if CONFIG_JUMP_LABEL=y

I am afraid some arches do not really have this.

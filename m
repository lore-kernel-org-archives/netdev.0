From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net-gre-gro: Add GRE support to the GRO stack
Date: Mon, 06 Jan 2014 13:40:41 -0800
Message-ID: <1389044441.26646.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1388896679-23152-1-git-send-email-hkchu@google.com>
	 <20140106.154330.1324356005311602000.davem@davemloft.net>
	 <20140106.161846.332183513263839789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:55548 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753702AbaAFVko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 16:40:44 -0500
Received: by mail-gg0-f174.google.com with SMTP id v2so3662801ggc.5
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 13:40:44 -0800 (PST)
In-Reply-To: <20140106.161846.332183513263839789.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-06 at 16:18 -0500, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 06 Jan 2014 15:43:30 -0500 (EST)
> 
> > That the gre offload bits won't be registered unless GRE is enabled and
> > initialized/loaded, right?
> 
> In fact, it's utterly and completely bogus to make only this change.
> It breaks the build, I'm reverting:
> 
> ERROR: "gre_offload_exit" [net/ipv4/gre.ko] undefined!
> ERROR: "gre_offload_init" [net/ipv4/gre.ko] undefined!
> --

Jerry, I'll send the patch to do this preparatory work in a small
and tested unit in the following hour.

Thanks.

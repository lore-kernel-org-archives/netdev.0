From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 0/3] net: Add GRO support for UDP
 encapsulating protocols
Date: Tue, 07 Jan 2014 08:45:47 -0800
Message-ID: <1389113147.26646.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, davem@davemloft.net, yanb@mellanox.com,
	shlomop@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:57369 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383AbaAGQpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 11:45:50 -0500
Received: by mail-pb0-f49.google.com with SMTP id jt11so344852pbb.36
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 08:45:49 -0800 (PST)
In-Reply-To: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-07 at 17:29 +0200, Or Gerlitz wrote:

> On my setup, which is net-next (now with the mlx4 vxlan offloads patches) -- 
> for single TCP session that goes through vxlan tunneling I got nice improvement
> from 6.8Gbs to 11.5Gbs

It would be nice to check how performance is impacted on a router, using
pktgen to inject UDP traffic on random UDP ports.

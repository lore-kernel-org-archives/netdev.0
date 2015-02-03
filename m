From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] pkt_sched: fq: better control of DDOS traffic
Date: Mon, 02 Feb 2015 19:34:03 -0800
Message-ID: <1422934443.21689.140.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1422626772.21689.90.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150202.181834.2201965486446161539.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:43411 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965802AbbBCDeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 22:34:07 -0500
Received: by mail-pa0-f52.google.com with SMTP id kx10so90433819pab.11
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 19:34:06 -0800 (PST)
In-Reply-To: <20150202.181834.2201965486446161539.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-02-02 at 18:18 -0800, David Miller wrote:

> Can you document the mask value a little bit more?
> 
> For example, I don't understand why "(1024 - 1) << 1" means 1024
> slots just from looking at this change.
> 

Sure , will do.

Thats because we reserve low order bit of the sk/hash value,
to make sure the stochastic hash is only applied on non locally
generated traffic.

Thanks

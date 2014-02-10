From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Mon, 10 Feb 2014 05:15:14 -0800
Message-ID: <1392038114.6615.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1390810971-23959-1-git-send-email-fw@strlen.de>
	 <1390810971-23959-2-git-send-email-fw@strlen.de>
	 <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140128085706.GB30123@breakpoint.cc>
	 <1390926883.28432.12.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140209025504.GB17395@gondor.apana.org.au>
	 <20140210122331.GA25153@breakpoint.cc>
	 <20140210123124.GA28752@gondor.apana.org.au>
	 <20140210124346.GA6329@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:55680 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223AbaBJNPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 08:15:16 -0500
Received: by mail-pb0-f51.google.com with SMTP id un15so6248294pbc.10
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 05:15:16 -0800 (PST)
In-Reply-To: <20140210124346.GA6329@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-10 at 13:43 +0100, Florian Westphal wrote:

> Well we could go with my original patch that will do software
> segmentation on ~DF packets in the forwarding path if the outmtu is too
> small for the individual packets.  The output path then simply
> creates fragments.

Most linux routers disable GRO anyway.

GRO is mostly used on linux hosts to improve performance, so most GRO
packets are consumed on the receiving host.

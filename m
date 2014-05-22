From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: initialise the itag variable in __mkroute_input
Date: Thu, 22 May 2014 11:21:29 -0700
Message-ID: <1400782889.5367.162.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400747815-3470-1-git-send-email-roy.qing.li@gmail.com>
	 <CAADnVQ+bvNGhrEqC3P3DqApjcXM3OUUHqTWJ+iwVmC3f4PguEw@mail.gmail.com>
	 <alpine.DEB.2.02.1405221111190.8647@dtop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	roy.qing.li@gmail.com, "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:34139 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbaEVSVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 14:21:31 -0400
Received: by mail-pb0-f47.google.com with SMTP id rp16so2844880pbb.6
        for <netdev@vger.kernel.org>; Thu, 22 May 2014 11:21:31 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1405221111190.8647@dtop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-22 at 11:13 -0700, dormando wrote:

> CONFIG_IP_ROUTE_CLASSID=y
> 
> There're a lot of negatives in that description, but if this patch only
> affects you if CONFIG_IP_ROUTE_CLASSID=n?

Yep


Have you tried Linus fix for pipes ?
(commit b0d8d2292160bb63de1972361ebed100c64b5b37 )

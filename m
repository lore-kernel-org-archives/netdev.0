From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: Re: [PATCH v2] ip: ip_options_compile() resilient to NULL skb route
Date: Fri, 15 Apr 2011 08:20:22 +0900
Message-ID: <20110415082022.b5e50f9b.shimoda.hiroaki@gmail.com>
References: <4DA522B2.90200@scotdoyle.com>
	<4DA5BCF7.9020606@scotdoyle.com>
	<1302708487.3725.0.camel@edumazet-laptop>
	<20110413.144812.116375845.davem@davemloft.net>
	<1302748276.3549.20.camel@edumazet-laptop>
	<20110413195424.1d2393c6@s6510>
	<1302750214.3549.34.camel@edumazet-laptop>
	<20110414123058.d4ffe7fb.shimoda.hiroaki@gmail.com>
	<1302796537.3248.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, lkml@scotdoyle.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:45261 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754472Ab1DNXU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 19:20:26 -0400
Received: by pwi15 with SMTP id 15so817131pwi.19
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2011 16:20:25 -0700 (PDT)
In-Reply-To: <1302796537.3248.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Apr 2011 17:55:37 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Scot Doyle demonstrated ip_options_compile() could be called with an skb
> without an attached route, using a setup involving a bridge, netfilter,
> and forged IP packets.
> 
> Let's make ip_options_compile() and ip_options_rcv_srr() a bit more
> robust, instead of changing bridge/netfilter code.
> 
> With help from Hiroaki SHIMODA.
> 
> Reported-by: Scot Doyle <lkml@scotdoyle.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Acked-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

Thanks.

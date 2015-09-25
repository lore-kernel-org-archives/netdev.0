From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 00/17] dccp/tcp: constify listener sock
Date: Fri, 25 Sep 2015 14:03:16 -0700
Message-ID: <1443214996.3273.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
	 <20150925.134242.2091340029551837446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, edumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33076 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933263AbbIYVDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 17:03:18 -0400
Received: by pacex6 with SMTP id ex6so115582615pac.0
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 14:03:17 -0700 (PDT)
In-Reply-To: <20150925.134242.2091340029551837446.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-09-25 at 13:42 -0700, David Miller wrote:
> From: Eric Dumazet <edumazet@google.com>
> Date: Fri, 25 Sep 2015 07:39:07 -0700
> 
> > Another patch bomb to prepare lockless TCP/DCCP LISTEN handling. 
> > 
> > SYNACK retransmits are built and sent without listener socket
> > being locked. Soon, initial SYNACK packets will have same property.
> > 
> > This series makes sure we did not something wrong with this model,
> > by adding a const qualifier in all the paths taken from synack building
> > and transmit, for IPv4/IPv6 and TCP/dccp.
> > 
> > The only potential problem was the rewrite of ecn bits for connections
> > with DCTCP as congestion module, but this was a very minor one.
>  ...
> > David, to apply these patches you'll need to merge net tree into net-next
> > first. Thanks !
> 
> I was able to apply them cleanly to net-next as-is, so I did so.

Ah, perfect then ;)

Thanks !

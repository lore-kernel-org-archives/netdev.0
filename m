From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 1/2] ipv6: constify inet6_protocol structures
Date: Tue, 1 Aug 2017 18:06:51 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1708011805340.21130@hadrien>
References: <1501273138-22771-1-git-send-email-Julia.Lawall@lip6.fr> <1501273138-22771-2-git-send-email-Julia.Lawall@lip6.fr> <1501495011.1876.12.camel@edumazet-glaptop3.roam.corp.google.com> <alpine.DEB.2.20.1708010759050.2671@hadrien>
 <63118b71-c196-efcd-0700-7c7c0025c577@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, bhumirks@gmail.com,
        netdev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:22413
        "EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751778AbdHAQHF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 12:07:05 -0400
In-Reply-To: <63118b71-c196-efcd-0700-7c7c0025c577@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 1 Aug 2017, David Ahern wrote:

> On 7/31/17 11:59 PM, Julia Lawall wrote:
> >> This change breaks the kernel if one of these sysctls are changed:
> >> tcp_early_demux, udp_early_demux
> >
> > The other patch in the series has the same problem and should be dropped
> > too.
> >
> > julia
>
> Julia: are you going to send a revert patch? Right now I have to do that
> manually before launching test scripts.

Sorry, I didn't know it was applied.  I can send it.

julia

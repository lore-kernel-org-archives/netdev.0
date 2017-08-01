From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH 1/2] ipv6: constify inet6_protocol structures
Date: Tue, 1 Aug 2017 10:03:41 -0600
Message-ID: <63118b71-c196-efcd-0700-7c7c0025c577@gmail.com>
References: <1501273138-22771-1-git-send-email-Julia.Lawall@lip6.fr>
 <1501273138-22771-2-git-send-email-Julia.Lawall@lip6.fr>
 <1501495011.1876.12.camel@edumazet-glaptop3.roam.corp.google.com>
 <alpine.DEB.2.20.1708010759050.2671@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, bhumirks@gmail.com,
        netdev <netdev@vger.kernel.org>
To: Julia Lawall <julia.lawall@lip6.fr>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35969 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751944AbdHAQDo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 12:03:44 -0400
Received: by mail-pf0-f169.google.com with SMTP id z129so9535780pfb.3
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 09:03:44 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.20.1708010759050.2671@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/31/17 11:59 PM, Julia Lawall wrote:
>> This change breaks the kernel if one of these sysctls are changed:
>> tcp_early_demux, udp_early_demux
> 
> The other patch in the series has the same problem and should be dropped
> too.
> 
> julia

Julia: are you going to send a revert patch? Right now I have to do that
manually before launching test scripts.

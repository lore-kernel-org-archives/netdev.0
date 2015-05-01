From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] pktgen: introduce 'rx' mode
Date: Fri, 01 May 2015 09:54:47 -0700
Message-ID: <1430499287.3711.121.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430457130-16003-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37260 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbbEAQyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 12:54:50 -0400
Received: by igblo3 with SMTP id lo3so41820413igb.0
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 09:54:49 -0700 (PDT)
In-Reply-To: <1430457130-16003-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-30 at 22:12 -0700, Alexei Starovoitov wrote:
> Introduce 'RX' mode for pktgen which generates the packets
> using familiar pktgen commands, but feeds them into
> netif_receive_skb() instead of ndo_start_xmit().

> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> v2->v3: addressed more Eric comments. Thanks!
> 
> v1->v2: as suggested by Eric:
> - dropped 'clone_skb' flag, now it will return enotsupp
> - fix rps/rfs bug by checking skb->users after every netif_receive_skb
> - tested with RPS/RFS, taps, veth, physical devs, various tc cls/act

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: pktgen: packet bursting via
 skb->xmit_more
Date: Tue, 30 Sep 2014 18:57:12 -0700
Message-ID: <1412128632.16704.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412124801-32096-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:47879 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbaJAB5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 21:57:23 -0400
Received: by mail-ig0-f177.google.com with SMTP id h3so139162igd.16
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 18:57:22 -0700 (PDT)
In-Reply-To: <1412124801-32096-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-30 at 17:53 -0700, Alexei Starovoitov wrote:
> This patch demonstrates the effect of delaying update of HW tailptr.
> (based on earlier patch by Jesper)
> 
> burst=1 is the default. It sends one packet with xmit_more=false
> burst=2 sends one packet with xmit_more=true and
>         2nd copy of the same packet with xmit_more=false
> burst=3 sends two copies of the same packet with xmit_more=true and
>         3rd copy with xmit_more=false
> 
> Performance with ixgbe (usec 30):
> burst=1  tx:9.2 Mpps
> burst=2  tx:13.5 Mpps
> burst=3  tx:14.5 Mpps full 10G line rate
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---

Very good, thanks Alexei

Signed-off-by: Eric Dumazet <edumazet@google.com>

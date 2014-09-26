From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next] net: pktgen: packet bursting via
 skb->xmit_more
Date: Thu, 25 Sep 2014 18:20:14 -0700
Message-ID: <1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:42017 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948AbaIZBUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 21:20:18 -0400
Received: by mail-pa0-f44.google.com with SMTP id eu11so11317234pac.31
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 18:20:17 -0700 (PDT)
In-Reply-To: <1411692382-8898-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-25 at 17:46 -0700, Alexei Starovoitov wrote:
> This patch demonstrates the effect of delaying update of HW tailptr.
> (based on earlier patch by Jesper)
> 
> burst=1 is a default. It sends one packet with xmit_more=false
> burst=2 sends one packet with xmit_more=true and
>         2nd copy of the same packet with xmit_more=false
> burst=3 sends two copies of the same packet with xmit_more=true and
>         3rd copy with xmit_more=false

> 
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---

Perfect, this is what I had in mind, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next] net: pktgen: packet bursting via
 skb->xmit_more
Date: Wed, 1 Oct 2014 10:16:36 +0200
Message-ID: <20141001101636.5aa27617@redhat.com>
References: <1412124801-32096-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	brouer@redhat.com
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11439 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750987AbaJAIQn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2014 04:16:43 -0400
In-Reply-To: <1412124801-32096-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Sep 2014 17:53:21 -0700
Alexei Starovoitov <ast@plumgrid.com> wrote:

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

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

Thanks Alexei

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

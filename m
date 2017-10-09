From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 0/2] ipv6: addrlabel: avoid dirtying
 ip6addrlbl_entry
Date: Mon, 9 Oct 2017 10:44:17 -0700
Message-ID: <20171009174417.gpfghoxctgksdzaz@kafai-mbp.dhcp.thefacebook.com>
References: <20171009165225.7008-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50648 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754310AbdJIRoZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 13:44:25 -0400
Content-Disposition: inline
In-Reply-To: <20171009165225.7008-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 09, 2017 at 04:52:23PM +0000, Eric Dumazet wrote:
> The refcount on ip6addrlbl_entry is only used to make sure ip6addrlbl_entry
> does not disappear while ip6addrlbl_get() is allocating an skb.
> 
> We can instead allocate skb first, then use RCU, so that we no longer need
> to refcount these structures.
Acked-by: Martin KaFai Lau <kafai@fb.com>

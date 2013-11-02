From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: flow_dissector: fail on evil iph->ihl
Date: Sat, 02 Nov 2013 02:16:51 -0400 (EDT)
Message-ID: <20131102.021651.96548203258073968.davem@davemloft.net>
References: <1383289270-18952-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pmatouse@redhat.com, mst@redhat.com,
	dborkman@redhat.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383289270-18952-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Fri,  1 Nov 2013 15:01:10 +0800

> We don't validate iph->ihl which may lead a dead loop if we meet a IPIP
> skb whose iph->ihl is zero. Fix this by failing immediately when iph->ihl
> is evil (less than 5).
> 
> This issue were introduced by commit ec5efe7946280d1e84603389a1030ccec0a767ae
> (rps: support IPIP encapsulation).
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Petr Matousek <pmatouse@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied and queued up for -stable, thanks Jason.

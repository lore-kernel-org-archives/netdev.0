From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix setting csum_start in skb_segment()
Date: Wed, 25 Jun 2014 20:46:13 -0700 (PDT)
Message-ID: <20140625.204613.736194500616545556.davem@davemloft.net>
References: <alpine.DEB.2.02.1406242056330.29780@tomh.mtv.corp.google.com>
	<1403725861.3796.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, torvalds@linux-foundation.org,
	davej@redhat.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403725861.3796.47.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Jun 2014 12:51:01 -0700

> From: Tom Herbert <therbert@google.com>
> 
> Dave Jones reported that a crash is occurring in
 ...
> It looks like a likely culprit is that SKB_GSO_CB()->csum_start is
> not set correctly when doing non-scatter gather. We are using
> offset as opposed to doffset.
> 
> Reported-by: Dave Jones <davej@redhat.com>
> Tested-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Tom Herbert <therbert@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 7e2b10c1e52ca ("net: Support for multiple checksums with gso")

Applied, thanks everyone.

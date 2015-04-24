From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: non contiguous allocations passed to build_skb
Date: Fri, 24 Apr 2015 15:02:54 -0700
Message-ID: <1429912974.22254.135.camel@edumazet-glaptop2.roam.corp.google.com>
References: <553AB56F.4000600@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <553AB56F.4000600@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-04-24 at 17:28 -0400, Sasha Levin wrote:
> Hey Eric,
> 
> Your commit 79930f5892e ("net: do not deplete pfmemalloc reserve") assumes that
> build_skb() will only handle contiguous allocations because of the
> virt_to_head_page().
> 
> However, netlink_sendmsg() calls build_skb() with vmalloc()ed memory, causing:

gosh. netlink & vmalloc() striked again.

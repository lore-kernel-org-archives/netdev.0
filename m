From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [GIT] Networking
Date: Thu, 6 Oct 2016 09:29:47 +1100
Message-ID: <20161006092947.25ae781c@canb.auug.org.au>
References: <20161005.014437.1946431553783736769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetFilter <netfilter-devel@vger.kernel.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Liping Zhang <liping.zhang@spreadtrum.com>
To: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20161005.014437.1946431553783736769.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Linus, Dave,

On Wed, 05 Oct 2016 01:44:37 -0400 (EDT) David Miller <davem@davemloft.net> wrote:
>

I have been carrying the following merge fix patch (for the merge of
the net-next tree with Linus' tree) for a while now which seems to have
got missed:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 13 Sep 2016 10:08:58 +1000
Subject: [PATCH] netfilter: merge fixup for "nf_tables_netdev: remove redundant ip_hdr assignment"

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/net/netfilter/nf_tables_ipv4.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/netfilter/nf_tables_ipv4.h b/include/net/netfilter/nf_tables_ipv4.h
index 968f00b82fb5..25e33aee91e7 100644
--- a/include/net/netfilter/nf_tables_ipv4.h
+++ b/include/net/netfilter/nf_tables_ipv4.h
@@ -33,7 +33,6 @@ __nft_set_pktinfo_ipv4_validate(struct nft_pktinfo *pkt,
 	if (!iph)
 		return -1;
 
-	iph = ip_hdr(skb);
 	if (iph->ihl < 5 || iph->version != 4)
 		return -1;
 
-- 
2.8.1

-- 
Cheers,
Stephen Rothwell

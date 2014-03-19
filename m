From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Tue, 18 Mar 2014 23:13:56 -0400 (EDT)
Message-ID: <20140318.231356.794206182931803937.davem@davemloft.net>
References: <20140318182752.ed10b8c685f31839f84a1ece@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, kaber@trash.net
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140318182752.ed10b8c685f31839f84a1ece@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 18 Mar 2014 18:27:52 +1100

> After merging the final tree, today's linux-next build (powerpc
> allyesconfig) failed like this:
> 
> net/netfilter/nft_hash.c: In function 'nft_hash_tbl_free':
> net/netfilter/nft_hash.c:79:3: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]

I've applied the patch below to fix this, thanks.

> Caused by commit ce6eb0d7c8ec ("netfilter: nft_hash: bug fixes and
> resizing") from the net-next tree.  See Rule 1 in
> Documentation/SubmitChecklist.

This slips through a lot, and would happen less often if core x86
headers didn't bring in vmalloc.h :-)

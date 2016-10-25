From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] netfilter: fix type mismatch with error return from
 nft_parse_u32_check
Date: Tue, 25 Oct 2016 15:55:56 -0400
Message-ID: <20161025195556.GA10443@tuxdriver.com>
References: <1477422484-27030-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Laura Garcia Liebana <nevola@gmail.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Dan Carpenter <dan.carpenter@oracle.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1477422484-27030-1-git-send-email-linville@tuxdriver.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 25, 2016 at 03:08:04PM -0400, John W. Linville wrote:
> Commit 36b701fae12ac ("netfilter: nf_tables: validate maximum value of
> u32 netlink attributes") introduced nft_parse_u32_check with a return
> value of "unsigned int", yet on error it returns "-ERANGE".
> 
> This patch corrects the mismatch by changing the return value to "int",
> which happens to match the actual users of nft_parse_u32_check already.
> 
> Found by Coverity, CID 1373930.
> 
> Note that commit 21a9e0f1568ea ("netfilter: nft_exthdr: fix error
> handling in nft_exthdr_init()) attempted to address the issue, but
> did not address the return type of nft_parse_u32_check.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> Cc: Laura Garcia Liebana <nevola@gmail.com>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Fixes: 0eadf37afc250 ("netfilter: nf_tables: validate maximum value...")

The Fixes line is incorrect -- corrected patch to follow!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

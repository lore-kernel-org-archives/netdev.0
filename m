From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] netfilter: fix type mismatch with error return from
 nft_parse_u32_check
Date: Thu, 27 Oct 2016 18:26:02 +0200
Message-ID: <20161027162602.GA10225@salvia>
References: <1477422484-27030-1-git-send-email-linville@tuxdriver.com>
 <1477425399-28480-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Laura Garcia Liebana <nevola@gmail.com>,
        Dan Carpenter <dan.carpenter@oracle.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1477425399-28480-1-git-send-email-linville@tuxdriver.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 25, 2016 at 03:56:39PM -0400, John W. Linville wrote:
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

Applied, thanks John.

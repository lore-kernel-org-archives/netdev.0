From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/3] netfilter: nf_tables: avoid uninitialized variable
 warning
Date: Fri, 30 Sep 2016 19:47:49 +0200
Message-ID: <20160930174749.GF1176@salvia>
References: <20160930160559.4102745-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160930160559.4102745-1-arnd@arndb.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 30, 2016 at 06:05:34PM +0200, Arnd Bergmann wrote:
> The newly added nft_range_eval() function handles the two possible
> nft range operations, but as the compiler warning points out,
> any unexpected value would lead to the 'mismatch' variable being
> used without being initialized:
> 
> net/netfilter/nft_range.c: In function 'nft_range_eval':
> net/netfilter/nft_range.c:45:5: error: 'mismatch' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This can be trivially avoided by added a 'default:' clause.

Applied this patch, I took Aaron's and Pai's patches instead.

Thanks anyway for following up on this issue Arnd.

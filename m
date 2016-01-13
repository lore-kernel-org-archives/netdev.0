From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: nft_ct: mark nft_ct_get_eval_counter
 __maybe_unused
Date: Wed, 13 Jan 2016 16:54:24 +0100
Message-ID: <20160113155424.GA1581@salvia>
References: <6200241.eeH6DHXzHj@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Florian Westphal <fw@strlen.de>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6200241.eeH6DHXzHj@wuerfel>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2016 at 02:58:11PM +0100, Arnd Bergmann wrote:
> The newly added nft_ct_get_eval_counter() function is only used when
> CONFIG_NF_CONNTRACK_LABELS is set, otherwise gcc warns about the
> unused definition:
> 
> netfilter/nft_ct.c:34:12: warning: 'nft_ct_get_eval_counter' defined but not used [-Wunused-function]
>  static u64 nft_ct_get_eval_counter(const struct nf_conn_counter *c,
> 
> This marks the function __maybe_unused to shut up the warning.

It seems that function doesn't below to CONFIG_NF_CONNTRACK_LABELS as
it is part of the new counter support. Will be sending an alternate
patch instead.

Thanks anyway for your patch Arnd.

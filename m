From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: Add dependency on IPV6 for NF_TABLES_INET
Date: Tue, 14 Jan 2014 16:34:54 +0100
Message-ID: <20140114153454.GA9425@localhost>
References: <1389636070-26312-1-git-send-email-paul.gortmaker@windriver.com>
 <85d5725b-16f8-464a-ad88-7def74571021@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <85d5725b-16f8-464a-ad88-7def74571021@email.android.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 14, 2014 at 11:35:42AM +0000, Patrick McHardy wrote:
> Paul Gortmaker <paul.gortmaker@windriver.com> schrieb:
> >Commit 1d49144c0aaa61be4e3ccbef9cc5c40b0ec5f2fe ("netfilter: nf_tables:
> >add "inet" table for IPv4/IPv6") allows creation of non-IPV6 enabled
> >.config files that will fail to configure/link as follows:
> >
> >warning: (NF_TABLES_INET) selects NF_TABLES_IPV6 which has unmet direct
> >dependencies (NET && INET && IPV6 && NETFILTER && NF_TABLES)
> >warning: (NF_TABLES_INET) selects NF_TABLES_IPV6 which has unmet direct
> >dependencies (NET && INET && IPV6 && NETFILTER && NF_TABLES)
> >warning: (NF_TABLES_INET) selects NF_TABLES_IPV6 which has unmet direct
> >dependencies (NET && INET && IPV6 && NETFILTER && NF_TABLES)
> >net/built-in.o: In function `nft_reject_eval':
> >nft_reject.c:(.text+0x651e8): undefined reference to `nf_ip6_checksum'
> >nft_reject.c:(.text+0x65270): undefined reference to `ip6_route_output'
> >nft_reject.c:(.text+0x656c4): undefined reference to `ip6_dst_hoplimit'
> >make: *** [vmlinux] Error 1
> >
> >Since the feature is to allow for a mixed IPV4 and IPV6 table, it
> >seems sensible to make it depend on IPV6.
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied, thanks.

@Paul: Please, use netfilter-devel ML instead next time. The netfilter
ML is reserved for user questions only. Thanks.

From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] netfilter: xt_TCPMSS: add more sanity tests on
 tcph->doff
Date: Sat, 8 Apr 2017 22:24:43 +0200
Message-ID: <20170408202443.GA3373@salvia>
References: <6c6e2f7505f969d8c2998efff24063ba@nuclearcat.com>
 <1491132259.10124.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <1491242111.10124.32.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1491242111.10124.32.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 03, 2017 at 10:55:11AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Denys provided an awesome KASAN report pointing to an use
> after free in xt_TCPMSS
> 
> I have provided three patches to fix this issue, either in xt_TCPMSS or
> in xt_tcpudp.c. It seems xt_TCPMSS patch has the smallest possible
> impact.

Applied to nf.git, thanks!

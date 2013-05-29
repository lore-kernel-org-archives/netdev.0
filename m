From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] iptables 1.4.19.1 release
Date: Wed, 29 May 2013 16:18:47 +0200
Message-ID: <20130529141847.GA18810@localhost>
References: <20130529133340.GA14566@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130529133340.GA14566@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I'm releasing 1.4.19.1

Unfortunately, the previous release was missing a couple of patches
that Florian applied that I didn't have in my tree.

Very sorry for the inconvenience.

On Wed, May 29, 2013 at 03:33:40PM +0200, Pablo Neira Ayuso wrote:
> Hi!
> 
> The Netfilter project proudly presents:
> 
>         iptables 1.4.19
> 
> This release includes support for the new connlabel and bpf matches
> available in Linux 3.9, several fixes and manpage updates.
> 
> See ChangeLog that comes attached to this email for more details.
> 
> You can download it from:
> 
> http://www.netfilter.org/projects/iptables/downloads.html
> ftp://ftp.netfilter.org/pub/iptables/
> 
> Have fun!
> 

> Florian Westphal (3):
>       libxt_NFQUEUE: fix bypass option documentation
>       extensions: add connlabel match
>       extensions: add connlabel match
> 
> Mart Frauenlob (3):
>       ip[6]tables: show --protocol instead of --proto in usage
>       libxt_recent: Fix missing space in manpage for --mask option
>       extensions: libxt_multiport: Update manpage to list valid protocols
> 
> Nicolas Dichtel (1):
>       utils: nfnl_osf: use the right nfnetlink lib
> 
> Pablo Neira Ayuso (11):
>       libip6t_NETMAP: Use xtables_ip6mask_to_cidr and get rid of libip6tc dependency
>       Revert "build: resolve link failure for ip6t_NETMAP"
>       libxt_osf: fix missing --ttl and --log in save output
>       libxt_osf: fix bad location for location in --genre
>       libip6t_SNPT: add manpage
>       libip6t_DNPT: add manpage
>       Merge branch 'stable'
>       utils: updates .gitignore to include nfbpf_compile
>       extensions: libxt_bpf: clarify --bytecode argument
>       libxtables: fix parsing of dotted network mask format
>       build: bump version to 1.4.19
> 
> Patrick McHardy (1):
>       libxt_conntrack: fix state match alias state parsing
> 
> Willem de Bruijn (2):
>       extensions: add libxt_bpf extension
>       utils: nfbpf_compile
> 


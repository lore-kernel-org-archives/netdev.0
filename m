From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: linux-next: Tree for Jun 18 (netfilter nfconntrack)
Date: Tue, 19 Jun 2012 05:19:38 +0200
Message-ID: <20120619031938.GA31266@1984>
References: <20120618165336.48345227c6b64c314326ae57@canb.auug.org.au>
 <4FDF65F6.6010002@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4FDF65F6.6010002@xenotime.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 18, 2012 at 10:31:34AM -0700, Randy Dunlap wrote:
> On 06/17/2012 11:53 PM, Stephen Rothwell wrote:
> 
> > Hi all,
> > 
> > Changes since 20120615:
> 
> 
> 
> on i386 or x86_64:
> 
> # CONFIG_NF_CONNTRACK is not set
> 
>   CC [M]  net/netfilter/nfnetlink_cthelper.o
> In file included from include/net/netfilter/nf_conntrack_helper.h:12:0,
>                  from net/netfilter/nfnetlink_cthelper.c:23:
> include/net/netfilter/nf_conntrack.h:77:22: error: field 'ct_general' has incomplete type
> include/net/netfilter/nf_conntrack.h: In function 'nf_ct_get':
> include/net/netfilter/nf_conntrack.h:157:30: error: 'const struct sk_buff' has no member named 'nfct'
> include/net/netfilter/nf_conntrack.h: In function 'nf_ct_put':
> include/net/netfilter/nf_conntrack.h:164:2: error: implicit declaration of function 'nf_conntrack_put'
> make[3]: *** [net/netfilter/nfnetlink_cthelper.o] Error 1

I've send a patch to David to solve this:

 netfilter: fix compilation of the nfnl_cthelper if NF_CONNTRACK is unset

It seems to resolve the issue for me here.

Thanks for the report.

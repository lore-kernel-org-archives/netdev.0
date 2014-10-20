From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/7] netfilter: missing module license in the
 nf_reject_ipvX modules
Date: Mon, 20 Oct 2014 12:54:44 +0200
Message-ID: <20141020105444.GA15796@salvia>
References: <1413792639-3954-1-git-send-email-pablo@netfilter.org>
 <1413792639-3954-2-git-send-email-pablo@netfilter.org>
 <5444E8BF.20904@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5444E8BF.20904@cogentembedded.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 20, 2014 at 02:49:35PM +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 10/20/2014 12:10 PM, Pablo Neira Ayuso wrote:
> 
> >[   23.545204] nf_reject_ipv4: module license 'unspecified' taints kernel.
> 
> >Fixes: c8d7b98 ("netfilter: move nf_send_resetX() code to nf_reject_ipvX modules")
> >Reported-by: Dave Young <dyoung@redhat.com>
> >Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> >---
> >  net/ipv4/netfilter/nf_reject_ipv4.c |    3 +++
> >  net/ipv6/netfilter/nf_reject_ipv6.c |    4 ++++
> >  2 files changed, 7 insertions(+)
> 
> [...]
> >diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
> >index 5f5f043..20d9def 100644
> >--- a/net/ipv6/netfilter/nf_reject_ipv6.c
> >+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
> >@@ -5,6 +5,8 @@
> >   * it under the terms of the GNU General Public License version 2 as
> >   * published by the Free Software Foundation.
> >   */
> >+
> >+#include <linux/module.h>
> >  #include <net/ipv6.h>
> >  #include <net/ip6_route.h>
> >  #include <net/ip6_fib.h>
> >@@ -161,3 +163,5 @@ void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
> >  		ip6_local_out(nskb);
> >  }
> >  EXPORT_SYMBOL_GPL(nf_send_reset6);
> >+
> >+MODULE_LICENSE("GPL");
> 
>    Actually, "GPL v2" as follows from the comment above.

We use that in all of the netfilter modules.

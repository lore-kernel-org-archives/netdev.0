From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: linux-next: Tree for Jun 21 (netfilter)
Date: Sat, 23 Jun 2012 02:19:04 +0200
Message-ID: <20120623001904.GA21360@1984>
References: <20120621161200.9f42414a528897bb016869e2@canb.auug.org.au>
 <4FE4AB02.9020100@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4FE4AB02.9020100@xenotime.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 22, 2012 at 10:27:30AM -0700, Randy Dunlap wrote:
> On 06/20/2012 11:12 PM, Stephen Rothwell wrote:
> 
> > Hi all,
> > 
> > Uploads to ra/geb.kernel.org are broken right now, so the tree will not
> > be available until that is fixed and I have uploaded it.
> > 
> > News: All my builds are now done with gcc 4.6.3 and binutils 2.22.
> > 
> > Changes since 20120620:
> 
> on x86_64:
> 
> net/netfilter/nf_conntrack_netlink.c:1644:9: error: implicit declaration of function 'ctnetlink_secctx_size'
> net/netfilter/nf_conntrack_netlink.c:1652:9: error: implicit declaration of function 'ctnetlink_proto_size'

I'll pass this patch to David to fix this issue:

http://1984.lsi.us.es/git/nf-next/commit/?id=8e36c4b5b673edc6081599b8bd461e062e4910f4

thanks for the report Randy.

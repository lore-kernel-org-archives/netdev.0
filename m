From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 23 Mar 2015 14:06:38 +0100
Message-ID: <20150323130638.GA6857@salvia>
References: <20150323140841.0b807b95@canb.auug.org.au>
 <20150323124723.GA6740@salvia>
 <1427115331.16851.11.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1427115331.16851.11.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 23, 2015 at 05:55:31AM -0700, Joe Perches wrote:
> On Mon, 2015-03-23 at 13:47 +0100, Pablo Neira Ayuso wrote:
> > On Mon, Mar 23, 2015 at 02:08:41PM +1100, Stephen Rothwell wrote:
> > > Today's linux-next merge of the net-next tree got a conflict in
> > > net/netfilter/nf_tables_core.c between commit 4017a7ee693d ("netfilter:
> > > restore rule tracing via nfnetlink_log") from the net tree and commit
> > > 01ef16c2dd2e ("netfilter: nf_tables: minor tracing cleanups") from the
> > > net-next tree.
> > > 
> > > I fixed it up (see below) and can carry the fix as necessary (no action
> > > is required).
> > "
> > This looks good, thanks for adressing this conflict Stephen.
> 
> trivia:
> 
> > > diff --cc net/netfilter/nf_tables_core.c
> []
> > > + static struct nf_loginfo trace_loginfo = {
> > > + 	.type = NF_LOG_TYPE_LOG,
> > > + 	.u = {
> > > + 		.log = {
> > > + 			.level = 4,
> 
> Perhaps all the .level = 4 uses should be LOGLEVEL_WARNING
> and .level = 5 should be LOGLEVEL_NOTICE

Yes, we can push a follow up patch to net-next changing all these
spots in the netfilter tree. Would you send a patch for this?

Thanks.

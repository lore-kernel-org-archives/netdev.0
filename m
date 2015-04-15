From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: linux-next: manual merge of the ftrace tree with the net-next
 tree
Date: Tue, 14 Apr 2015 23:06:29 -0400
Message-ID: <20150414230629.78b83480@grimm.local.home>
References: <20150413175224.73a9baff@canb.auug.org.au>
	<20150415112323.057080ad@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.232]:47034 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754079AbbDODGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 23:06:24 -0400
In-Reply-To: <20150415112323.057080ad@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Apr 2015 11:23:23 +1000
Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi all,
> 
> On Mon, 13 Apr 2015 17:52:24 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> >
> > Today's linux-next merge of the ftrace tree got a conflict in
> > drivers/net/wireless/iwlwifi/iwl-devtrace.h between commit 7e1223b50089
> > ("iwlwifi: mvm: new Alive / error table API") from the net-next tree
> > and commit c5ef935d01a2 ("iwlwifi: Move each system tracepoints to
> > their own header") from the ftrace tree.
> > 
> > I fixed it up (see patch below, since this code was moved to a new file)
> > and can carry the fix as necessary (no action is required).
> > 
> > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > Date: Mon, 13 Apr 2015 17:21:30 +1000
> > Subject: [PATCH] iwlwifi: mvm: fix up for tracing split
> > 
> > Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>


> This patch is now needed when the net-next tree is merged with Linus'
> tree ...

I also noted this coming conflict in my pull request. So Linus should
be very well aware of it.

 https://lkml.org/lkml/2015/4/13/652

"Also there's a conflict with commit 7e1223b50089 ("iwlwifi: mvm: new
Alive / error table API") that Stephen found and he resolved it with
cd98c1ef4ec1a4d08e920060b70e47a5a4e69377."

That is, if that commit sha1 still exists.

-- Steve

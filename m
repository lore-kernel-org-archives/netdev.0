From: Per Liden <per.liden@ericsson.com>
Subject: Re: [PATCH 0/14] TIPC updates
Date: Wed, 18 Oct 2006 10:24:26 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0610181012110.16574@ulinpc219.uab.ericsson.se>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
 <20061016.220428.55725878.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:63723 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1750882AbWJRIYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 04:24:30 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061016.220428.55725878.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Oct 2006, David Miller wrote:

> From: Per Liden <per.liden@ericsson.com>
> Date: Fri, 13 Oct 2006 13:37:23 +0200 (CEST)
> 
> > This patch set includes a number TIPC fixes/cleanups. Please see each 
> > individual patch for further description.
> > 
> > Please pull from:
> > 
> >  git://tipc.cslab.ericsson.net/pub/git/tipc.git
> > 
> >  (rebased on linux/kernel/git/davem/net-2.6.git)
> 
> I applied everything except patch 8/14, you really need to
> add proper SKB queue locking to handle that race.  I think
> the "performance cost" of taking that lock is much overstated,
> you should never have contention on that lock at all.

Ok, we'll take your advice on this.

> Secondly, I never pull from your trees because I still have
> to make many fixups to your patches:
> 
> 1) Please add a proper colon to your changeset header lines,
>    it should be "[TIPC]: ", not "[TIPC] ".
>
> 2) Please check for trailing whitespace added by your patches.
>    I've given you the command you can use in another email to
>    check this for yourselve before submission.
> 
> 3) Please get full proper signed-off-by lines from patch submitters,
>    especially when the patch is more than a trivial 1 or 2 liner.

Thanks a lot for the feedback. We'll do our best to assure that we follow 
these rules in the future.

/Per

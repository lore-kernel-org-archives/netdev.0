From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/14] TIPC updates
Date: Mon, 16 Oct 2006 22:04:28 -0700 (PDT)
Message-ID: <20061016.220428.55725878.davem@davemloft.net>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41105
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423075AbWJQFE1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 01:04:27 -0400
To: per.liden@ericsson.com
In-Reply-To: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Per Liden <per.liden@ericsson.com>
Date: Fri, 13 Oct 2006 13:37:23 +0200 (CEST)

> This patch set includes a number TIPC fixes/cleanups. Please see each 
> individual patch for further description.
> 
> Please pull from:
> 
>  git://tipc.cslab.ericsson.net/pub/git/tipc.git
> 
>  (rebased on linux/kernel/git/davem/net-2.6.git)

I applied everything except patch 8/14, you really need to
add proper SKB queue locking to handle that race.  I think
the "performance cost" of taking that lock is much overstated,
you should never have contention on that lock at all.

Secondly, I never pull from your trees because I still have
to make many fixups to your patches:

1) Please add a proper colon to your changeset header lines,
   it should be "[TIPC]: ", not "[TIPC] ".

2) Please check for trailing whitespace added by your patches.
   I've given you the command you can use in another email to
   check this for yourselve before submission.

3) Please get full proper signed-off-by lines from patch submitters,
   especially when the patch is more than a trivial 1 or 2 liner.

Thanks.

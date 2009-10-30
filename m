From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 4/7] fsl_pq_mdio: Add Suport for etsec2.0 devices.
Date: Thu, 29 Oct 2009 21:21:42 -0700 (PDT)
Message-ID: <20091029.212142.189578068.davem@davemloft.net>
References: <1256826229-529-1-git-send-email-Sandeep.Kumar@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com
To: Sandeep.Kumar@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34164
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750963AbZJ3EVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 00:21:18 -0400
In-Reply-To: <1256826229-529-1-git-send-email-Sandeep.Kumar@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
Date: Thu, 29 Oct 2009 19:53:49 +0530

> From: Sandeep Gopalpet <sandeep.kumar@freescale.com>
> 
> This patch adds mdio support for etsec2.0 devices.
> 
> Modified the fsl_pq_mdio structure to include the new mdio
> members.
> 
> Signed-off-by: Sandeep Gopalpet <sandeep.kumar@freescale.com>
> ---
>  *. Rebased to the net-next-2.6 tree as of 20091028 cloned from
>     http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git

It does not apply, again.

And again, here is the bundle I tried to apply using "git am --signoff":

	http://vger.kernel.org/~davem/bundle-641.mbox

--------------------
davem@sunset:~/src/GIT/net-next-2.6$ git am --signoff bundle-641.mbox 
Applying: gianfar: Add per queue structure support
Applying: gianfar: Introduce logical group support.
Applying: gianfar: Add Multiple Queue Support
Applying: fsl_pq_mdio: Add Suport for etsec2.0 devices.
error: patch failed: drivers/net/fsl_pq_mdio.c:405
error: drivers/net/fsl_pq_mdio.c: patch does not apply
Patch failed at 0004 fsl_pq_mdio: Add Suport for etsec2.0 devices.
When you have resolved this problem run "git am --resolved".
If you would prefer to skip this patch, instead run "git am --skip".
To restore the original branch and stop patching run "git am --abort".
--------------------

Did you try the bundle I posted yesterday which failed?  This
one is identical, you didn't change anything.

This is getting rediculious.

Try again, and when you do take the patches from patchwork at:

	http://patchwork.ozlabs.org/project/netdev/list/

and you try to apply them to net-next-2.6 using git (_not_ 'patch',
'patch' is way too lenient about fuzz and line offsets) so that you
can see what's happening.

I'm completely ignoring your patch postings until you sort this out.

You cannot have line offsets or fuzz when you send patches that are to
be applied by GIT, and that is the problem with patch #4:

davem@sunset:~/src/GIT/net-next-2.6$ patch -p1 <diff
patching file drivers/net/fsl_pq_mdio.c
Hunk #6 succeeded at 436 with fuzz 1.
patching file drivers/net/fsl_pq_mdio.h

GIT does not allow line fuzz, you must make absolutely pristine
patches, and therefore if you are testing your submission with just
'patch' that absolutely will not work.

Thanks.

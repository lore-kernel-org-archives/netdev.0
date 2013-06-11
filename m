From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net 0/5] vxlan stability patches
Date: Tue, 11 Jun 2013 01:52:12 -0700 (PDT)
Message-ID: <20130611.015212.65163212261749972.davem@davemloft.net>
References: <20130610173709.0356a2d2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753761Ab3FKIwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 04:52:15 -0400
In-Reply-To: <20130610173709.0356a2d2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 10 Jun 2013 17:37:09 -0700

> Test (non-stress) has been run on each patch.

These patches still do not apply to 'net':

[davem@dokdo net]$ git am --signoff bundle-4421-vxlan-net.mbox 
Applying: vxlan: only migrate dynamic FDB entries
Applying: vxlan: handle skb_clone failure
Applying: vxlan: fix crash on module removal
Applying: vxlan: fix crash from work pending on module removal
error: patch failed: drivers/net/vxlan.c:148
error: drivers/net/vxlan.c: patch does not apply
Patch failed at 0004 vxlan: fix crash from work pending on module removal
The copy of the patch that failed is found in:
   /home/davem/src/GIT/net/.git/rebase-apply/patch
When you have resolved this problem run "git am --resolved".
If you would prefer to skip this patch, instead run "git am --skip".
To restore the original branch and stop patching run "git am --abort".

Please submit these changes properly, and it should be very clear
to you that I am losing my patience.

Linus at this point wants only the most important fixes, and we've
gone through two iterations of these changes, each of which either
don't compile, or aren't grouped properly and therefore don't even
apply cleanly to my tree.

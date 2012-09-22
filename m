From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rds: Error on offset mismatch if not loopback
Date: Sat, 22 Sep 2012 15:25:24 -0400 (EDT)
Message-ID: <20120922.152524.1294103117346567757.davem@davemloft.net>
References: <20120921213239.GJ14393@linux-tkdk.sfcn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, venkat.x.venkatsubra@oracle.com,
	netdev@vger.kernel.org
To: jjolly@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527Ab2IVTZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 15:25:26 -0400
In-Reply-To: <20120921213239.GJ14393@linux-tkdk.sfcn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Jolly <jjolly@suse.com>
Date: Fri, 21 Sep 2012 15:32:40 -0600

> Attempting an rds connection from the IP address of an IPoIB interface
> to itself causes a kernel panic due to a BUG_ON() being triggered.
> Making the test less strict allows rds-ping to work without crashing
> the machine.
> 
> A local unprivileged user could use this flaw to crash the system.
> 
> Signed-off-by: John Jolly <jjolly@suse.com>

Besides the questions being asked of you by Venkat Venkatsubra, this
patch has another issue.

It has been completely corrupted by your email client, it has
turned all TAB characters into spaces, making the patch useless.

Please learn how to send a patch unmolested in the body of your
email.  Test it by emailing the patch to yourself, and verifying
that you can in fact apply the patch you receive in that email.
Then, and only then, should you consider making a new submission
of this patch.

Use Documentation/email-clients.txt for guidance.

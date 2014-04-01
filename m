From: David Miller <davem@davemloft.net>
Subject: Re: Bug in ks8851.c
Date: Tue, 01 Apr 2014 18:13:55 -0400 (EDT)
Message-ID: <20140401.181355.1375673242692769955.davem@davemloft.net>
References: <9525F3D6E0E9E64DA832F2587811AD6A200C24@USRAL1WVEXC01.elt.lcl>
	<b703c70840da4780bc93beed79a8503b@DB3PR02MB202.eurprd02.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	sboyd@codeaurora.org, mjr@cs.wisc.edu, jiri@resnulli.us,
	linux-kernel@vger.kernel.org, trivial@rustcorp.com.au
To: Max.Nekludov@elster.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56314 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbaDAWN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 18:13:58 -0400
In-Reply-To: <b703c70840da4780bc93beed79a8503b@DB3PR02MB202.eurprd02.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nekludov, Max" <Max.Nekludov@elster.com>
Date: Tue, 1 Apr 2014 15:41:58 +0000

> Reset on RX failure and TX timeout.
> 
> Electromagnetic noice can make device to not send TX interrupts.
> As result outgoing queue will be suspended forever.
> Also EMI can raise RX interrupt with zero value in KS_RXFC register.
> 
> Patch attached.

netdev@vger.kernel.org and the driver maintainer (as listed in
MAINTAINERS) is sufficient for submitting this patch, lists
such as 'trivial' and sending such patches to Linus directly
is not really appropriate.

As per your patch, please do not submit it as an attachment,
as per Documentation/SubmittingPatches, it should be the main
content with the commit message header line being in your
Subject.

Furthermore, in:

+static void ks8851_wdt_work(struct delayed_work *work)
+{
+	struct ks8851_net *ks = container_of(work, struct ks8851_net, wdt_work);
+	mutex_lock(&ks->lock);

You should have an empty line beteen local variable declarations
and where real code starts.

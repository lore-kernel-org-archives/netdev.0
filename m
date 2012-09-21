From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3 V2] phy/micrel: Implement support for KSZ8021
Date: Fri, 21 Sep 2012 15:11:04 -0400 (EDT)
Message-ID: <20120921.151104.718226045755546422.davem@davemloft.net>
References: <201209212050.46319.marex@denx.de>
	<20120921.145405.646315503417542108.davem@davemloft.net>
	<201209212106.53069.marex@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.choi@micrel.com,
	nobuhiro.iwamatsu.yj@renesas.com, fabio.estevam@freescale.com,
	shawn.guo@linaro.org
To: marex@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674Ab2IUTLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 15:11:07 -0400
In-Reply-To: <201209212106.53069.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Vasut <marex@denx.de>
Date: Fri, 21 Sep 2012 21:06:52 +0200

> You know, youth and all ... I was under the impression the patches shall be 
> checkpatch clean. But you got me there quite well, something must be wrong with 
> my precommit hook.

checkpatch is not a panacea, and it is in particular not an automaton
that one uses without using any human judgement at all.

In particular, checkpatch does not enforce the comment style we use in
the networking code nor several other conventions that we use which
are slightly different from the rest of the tree.

Therefore strick checkpatch conformance is never appropriate.

> Anyway, about the checkpatch cleanup of the file, will that be 
> welcome (afterwards I fix the patchset and repost)?

See above, strict checkpatch cleanups, especially those done in
a completely automaton style with zero human judgment involved,
are not welcome.

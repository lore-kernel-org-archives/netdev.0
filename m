From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH 1/3 V2] phy/micrel: Implement support for KSZ8021
Date: Fri, 21 Sep 2012 21:19:17 +0200
Message-ID: <201209212119.18155.marex@denx.de>
References: <201209212050.46319.marex@denx.de> <201209212106.53069.marex@denx.de> <20120921.151104.718226045755546422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.choi@micrel.com,
	nobuhiro.iwamatsu.yj@renesas.com, fabio.estevam@freescale.com,
	shawn.guo@linaro.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:56951 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755906Ab2IUTTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 15:19:19 -0400
In-Reply-To: <20120921.151104.718226045755546422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David Miller,

> From: Marek Vasut <marex@denx.de>
> Date: Fri, 21 Sep 2012 21:06:52 +0200
> 
> > You know, youth and all ... I was under the impression the patches shall
> > be checkpatch clean. But you got me there quite well, something must be
> > wrong with my precommit hook.
> 
> checkpatch is not a panacea, and it is in particular not an automaton
> that one uses without using any human judgement at all.
> 
> In particular, checkpatch does not enforce the comment style we use in
> the networking code nor several other conventions that we use which
> are slightly different from the rest of the tree.
> 
> Therefore strick checkpatch conformance is never appropriate.

Understood.

> > Anyway, about the checkpatch cleanup of the file, will that be
> > welcome (afterwards I fix the patchset and repost)?
> 
> See above, strict checkpatch cleanups, especially those done in
> a completely automaton style with zero human judgment involved,
> are not welcome.

I meant the .features field ... it seems that the | at the following line 
appears in other PHY drivers as well though. Lets leave it at that anyway.

Best regards,
Marek Vasut

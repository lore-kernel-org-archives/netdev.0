From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] l2tp: fix namespace support in l2tp_core
Date: Tue, 05 Feb 2013 13:56:53 -0500 (EST)
Message-ID: <20130205.135653.191570417358997040.davem@davemloft.net>
References: <1359711783-4379-1-git-send-email-tparkin@katalix.com>
	<20130204.132107.47370979625013842.davem@davemloft.net>
	<20130205092709.GA2465@raven>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com, celston@katalix.com
To: tparkin@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57950 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756179Ab3BES45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 13:56:57 -0500
In-Reply-To: <20130205092709.GA2465@raven>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Parkin <tparkin@katalix.com>
Date: Tue, 5 Feb 2013 09:27:09 +0000

> On Mon, Feb 04, 2013 at 01:21:07PM -0500, David Miller wrote:
>> 
>> These patches don't apply cleanly to net-next, please respin.
> 
> Hmm.  I think the problem is that this patchset builds on the bug-fix
> work of this previous submission:
> 
>   * l2tp: prevent l2tp_tunnel_delete racing with userspace close
> 
> The bug fix patch went to the net tree, not net-next, hence the
> problem.  I should have made the dependency between the two patches
> more explicit -- apologies for not having done so!
> 
> What's the right thing for me to do in a situation like this?  Should
> I wait and resubmit when net-next and net are next synchronised?

The best thing to do is tell me about the dependency, then I can
pull 'net' into 'net-next' before applying your patches.

I'll do that right now.

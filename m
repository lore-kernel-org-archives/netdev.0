From: David Miller <davem@davemloft.net>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Fri, 13 Jun 2008 02:32:08 -0700 (PDT)
Message-ID: <20080613.023208.78649628.davem@davemloft.net>
References: <20080611.165255.242691774.davem@davemloft.net>
	<20080612.163212.148965080.davem@davemloft.net>
	<20080613063037.GA16943@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, vgusev@openvz.org, mcmanus@ducksong.com,
	xemul@openvz.org, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55531
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755520AbYFMJcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 05:32:08 -0400
In-Reply-To: <20080613063037.GA16943@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 13 Jun 2008 08:30:37 +0200

> the 3 reverts have been extensively tested in -tip via:
> 
>  # tip/out-of-tree: 9e5b6ca: tcp: revert DEFER_ACCEPT modifications
> 
> and the distcc problems are fixed. (The locking fix alone did not fix it 
> conclusively in my testing, possibly due to the follow-on observations 
> outlined in your description.)
> 
> Tested-by: Ingo Molnar <mingo@elte.hu>

I didn't revert all three changes, just the final part of that
3 part series.

Please test the patch I actually applied.

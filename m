From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8736] New: New TC deadlock scenario
Date: Sun, 15 Jul 2007 16:21:13 +0200
Message-ID: <469A2D59.6080209@trash.net>
References: <469521F0.1010803@trash.net>	<4698EF3B.5070907@trash.net>	<1184431535.14136.62.camel@localhost.localdomain> <20070714.204951.112046547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: ranko@spidernet.net, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@kernel-bugs.osdl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58704 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757502AbXGOOWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 10:22:23 -0400
In-Reply-To: <20070714.204951.112046547.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ranko Zivojnovic <ranko@spidernet.net>
> Date: Sat, 14 Jul 2007 19:45:35 +0300
> 
> 
>>>>Please try reverting commit 1936502d00ae6c2aa3931c42f6cf54afaba094f2,
>>>>that should fix it.
>>>
>>>
>>>Ranko, did you get a chance to test this? I've attached the patch
>>>since it doesn't revert cleanly ..
>>
>>I have the commit reverted on my tree and have been testing it along
>>with the other changes to qdisc code I'm currently doing and it does
>>rectify the problem.
>>
>>Acked-by: Ranko Zivojnovic <ranko@spidernet.net>
> 
> 
> Applied, thanks everyone.


This one is a regression in 2.6.22, so the patch should also go
in -stable IMO.


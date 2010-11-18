From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.37-rc2] Fix duplicate volatile warning.
Date: Thu, 18 Nov 2010 09:40:22 -0800 (PST)
Message-ID: <20101118.094022.115931453.davem@davemloft.net>
References: <201011180403.oAI43JBT005077@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37410
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755267Ab0KRRj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 12:39:58 -0500
In-Reply-To: <201011180403.oAI43JBT005077@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 18 Nov 2010 13:03:19 +0900

>>From a391f571f21bfa81369599f03e86fa75589291a3 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Thu, 18 Nov 2010 12:44:26 +0900
> Subject: [PATCH 2.6.37-rc2] Fix duplicate volatile warning.
> 
> jiffies is defined as "volatile".
> 
>   extern unsigned long volatile __jiffy_data jiffies;
> 
> ACCESS_ONCE() uses "volatile".
> As a result, some compilers warn duplicate `volatile' for ACCESS_ONCE(jiffies).
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Fair enough, applied, thanks.

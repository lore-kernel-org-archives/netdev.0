From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] filter: Optimize instruction revalidation code.
Date: Thu, 18 Nov 2010 10:58:58 -0800 (PST)
Message-ID: <20101118.105858.232753145.davem@davemloft.net>
References: <201011162331.CGH00026.OFOSFVMFQtLHOJ@I-love.SAKURA.ne.jp>
	<1289925055.5372.484.camel@edumazet-laptop>
	<201011170119.oAH1JpES011121@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mjt@tls.msk.ru, drosenberg@vsecurity.com, hagen@jauu.net,
	xiaosuo@gmail.com, netdev@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45854
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753693Ab0KRS6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 13:58:33 -0500
In-Reply-To: <201011170119.oAH1JpES011121@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 17 Nov 2010 10:19:51 +0900

> Subject: [PATCH v3] filter: Optimize instruction revalidation code.
> 
> Since repeating u16 value to u8 value conversion using switch() clause's
> case statement is wasteful, this patch introduces u16 to u8 mapping table
> and removes most of case statements. As a result, the size of net/core/filter.o
> is reduced by about 29% on x86.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Applied, thank you.

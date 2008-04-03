From: David Miller <davem@davemloft.net>
Subject: Re: [PING^3] [PATCH] srandom32 fixes for networking v2
Date: Thu, 03 Apr 2008 14:07:23 -0700 (PDT)
Message-ID: <20080403.140723.249778614.davem@davemloft.net>
References: <20080403203611.GA25305@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60156
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755248AbYDCVHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 17:07:23 -0400
In-Reply-To: <20080403203611.GA25305@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Thu, 3 Apr 2008 22:36:11 +0200

> srandom32 fixes for networking v2
> 
> - Let it update the state of all CPUs. The network stack goes
> into pains to feed the current IP addresses in, but it is not very
> effective if that is only done for some random CPU instead of all.
> So change it to feed bits into all CPUs.  I decided to do that lockless 
> because well somewhat random results are ok.
> 
> v2: Drop rename so that this patch doesn't depend on x86 maintainers
> 
> Signed-off-by: Andi Kleen <ak@suse.de>

Applied, thanks.

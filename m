From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_cubic: faster cube root
Date: Tue, 06 Mar 2007 20:20:52 -0800 (PST)
Message-ID: <20070306.202052.03980320.davem@davemloft.net>
References: <20070306102941.32471d57@freekitty>
	<20070306.135834.26100913.davem@davemloft.net>
	<20070306144706.4585c079@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rkuhn@e18.physik.tu-muenchen.de, andi@firstfloor.org,
	dada1@cosmosbay.com, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42743
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161282AbXCGEUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 23:20:55 -0500
In-Reply-To: <20070306144706.4585c079@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 6 Mar 2007 14:47:06 -0800

> The Newton-Raphson method is quadratically convergent so
> only a small fixed number of steps are necessary.
> Therefore it is faster to unroll the loop. Since div64_64 is no longer
> inline it won't cause code explosion.
> 
> Also fixes a bug that can occur if x^2 was bigger than 32 bits.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, thanks Stephen.

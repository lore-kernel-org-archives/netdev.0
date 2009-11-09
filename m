From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: SAD entries do not expire correctly after
 suspend-resume
Date: Sun, 08 Nov 2009 20:58:59 -0800 (PST)
Message-ID: <20091108.205859.180271806.davem@davemloft.net>
References: <20091108211249.2ecdfd38@penta.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peterz@infradead.org,
	yoshfuji@linux-ipv6.org, tglx@linutronix.de, mingo@elte.hu
To: ypolyans@princeton.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51264
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754154AbZKIE6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 23:58:34 -0500
In-Reply-To: <20091108211249.2ecdfd38@penta.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yury Polyanskiy <ypolyans@princeton.edu>
Date: Sun, 8 Nov 2009 21:12:49 -0500

> 
>   This fixes the following bug in the current implementation of
> net/xfrm: SAD entries timeouts do not count the time spent by the machine 
> in the suspended state. This leads to the connectivity problems because 
> after resuming local machine thinks that the SAD entry is still valid, while 
> it has already been expired on the remote server.
 ...
> Signed-off-by: Yury Polyanskiy <polyanskiy@gmail.com>

Applied to net-next-2.6, thanks for following up on this.

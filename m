From: David Miller <davem@davemloft.net>
Subject: Re: [AX.25] Optimize AX.25 socket list lock
Date: Wed, 12 Jul 2006 13:25:36 -0700 (PDT)
Message-ID: <20060712.132536.57354597.davem@davemloft.net>
References: <20060711222045.GA5823@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19091
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750850AbWGLUYs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 16:24:48 -0400
To: ralf@linux-mips.org
In-Reply-To: <20060711222045.GA5823@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Tue, 11 Jul 2006 23:20:45 +0100

> Right now all uses of the ax25_list_lock lock are _bh locks but knowing
> some code is only ever getting invoked from _bh context we can better.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks Ralf.

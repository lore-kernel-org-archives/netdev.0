From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.29] ucc_geth: Fix oops when using fixed-link support
Date: Sun, 22 Mar 2009 21:31:22 -0700 (PDT)
Message-ID: <20090322.213122.199224311.davem@davemloft.net>
References: <20090320223417.GA20018@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joakim.Tjernlund@transmode.se, leoli@freescale.com,
	Haiying.Wang@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45939
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750762AbZCWEbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 00:31:34 -0400
In-Reply-To: <20090320223417.GA20018@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Sat, 21 Mar 2009 01:34:17 +0300

> commit b1c4a9dddf09fe99b8f88252718ac5b357363dc4 ("ucc_geth: Change
> uec phy id to the same format as gianfar's") introduced a regression
> in the ucc_geth driver that causes this oops when fixed-link is used:
> 
> Unable to handle kernel paging request for data at address 0x00000000
> Faulting instruction address: 0xc0151270
...
> Reported-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> Tested-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>

Applied, thanks.

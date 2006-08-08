From: David Miller <davem@davemloft.net>
Subject: Re: [-mm patch] net/: make code static
Date: Mon, 07 Aug 2006 21:51:52 -0700 (PDT)
Message-ID: <20060807.215152.98863622.davem@davemloft.net>
References: <20060806030809.2cfb0b1e.akpm@osdl.org>
	<20060807154947.GE3691@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27556
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932490AbWHHEvv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 00:51:51 -0400
To: bunk@stusta.de
In-Reply-To: <20060807154947.GE3691@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Mon, 7 Aug 2006 17:49:47 +0200

> This patch makes needlessly global code static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Looks reasonable, applied.

> It doesn't seem to be intended that the new
> ipv4/fib_rules.c:fib4_rules_cleanup() is completely unused?

I'll kill it off.

IPv4 can't be built as a module and therefore there is no
relevant exit or module load error path for ipv4 for which
this function should be called.

Thanks.

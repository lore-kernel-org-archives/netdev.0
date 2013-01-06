From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Major network performance regression in 3.7
Date: Sat, 05 Jan 2013 18:44:15 -0800
Message-ID: <1357440255.1678.5270.camel@edumazet-glaptop>
References: <20130105232913.GQ16031@1wt.eu>
	 <1357430523.1678.4901.camel@edumazet-glaptop>
	 <20130106005053.GS16031@1wt.eu>
	 <1357435276.1678.5067.camel@edumazet-glaptop>
	 <20130106013027.GV16031@1wt.eu>
	 <1357436430.1678.5111.camel@edumazet-glaptop>
	 <1357437086.1678.5135.camel@edumazet-glaptop>
	 <1357438591.1678.5205.camel@edumazet-glaptop>
	 <20130106021824.GW16031@1wt.eu>
	 <1357438933.1678.5223.camel@edumazet-glaptop>
	 <20130106023206.GX16031@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:38334 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754959Ab3AFCoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 21:44:19 -0500
In-Reply-To: <20130106023206.GX16031@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-01-06 at 03:32 +0100, Willy Tarreau wrote:

> It's 0cf833ae (net: loopback: set default mtu to 64K). And I could
> reproduce it with 3.6 by setting loopback's MTU to 65536 by hand.
> The trick is that once the MTU has been set to this large a value,
> even when I set it back to 16kB the problem persists.
> 

Well, this MTU change can uncover a prior bug, or make it happen faster,
for sure.

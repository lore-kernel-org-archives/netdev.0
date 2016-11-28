From: David Miller <davem@davemloft.net>
Subject: Re: stmmac ethernet in kernel 4.4: coalescing related pauses?
Date: Mon, 28 Nov 2016 11:30:31 -0500 (EST)
Message-ID: <20161128.113031.964579744326063048.davem@davemloft.net>
References: <20161128.095431.856183735501262965.davem@davemloft.net>
        <1480347103.18162.58.camel@edumazet-glaptop3.roam.corp.google.com>
        <920b1148-a77d-0b69-01b0-b14bcbdf8648@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, pavel@ucw.cz, peppe.cavallaro@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: lsanfil@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60876 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754728AbcK1Qad (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 11:30:33 -0500
In-Reply-To: <920b1148-a77d-0b69-01b0-b14bcbdf8648@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lino Sanfilippo <lsanfil@marvell.com>
Date: Mon, 28 Nov 2016 16:57:35 +0100

> I wonder if the best fix would be indeed to deactivate irq coalescing
> completely.
> Does it make any sense at all to use it if a driver uses NAPI already?

It absolutely does make sense, when it is implemented and functions
properly.

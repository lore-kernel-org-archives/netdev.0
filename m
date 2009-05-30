From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH V2] mlx4_en: Fix a kernel panic when waking tx
 queue
Date: Fri, 29 May 2009 22:00:38 -0700 (PDT)
Message-ID: <20090529.220038.240580987.davem@davemloft.net>
References: <4A1948D7.8010504@mellanox.co.il>
	<4A1A57AA.1080209@mellanox.co.il>
	<4A1B92D1.8070907@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58200
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751080AbZE3FAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 01:00:38 -0400
In-Reply-To: <4A1B92D1.8070907@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Tue, 26 May 2009 09:57:21 +0300

> When the transmit queue gets full we enable interrupts for TX completions
> There was a race that we handled the TX queue both from the interrupt context
> and from the transmit function. Using "spin_trylock_irq()" ensures this
> doesn't happen.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

I'll apply this, thanks.

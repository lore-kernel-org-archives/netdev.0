From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: correct uninitialized queue_map
Date: Mon, 08 Nov 2010 12:19:55 -0800 (PST)
Message-ID: <20101108.121955.39191326.davem@davemloft.net>
References: <20101108091941.GB5025@Desktop-Junchang>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, eric.dumazet@gmail.com, joe@perches.com,
	andy.shevchenko@gmail.com, backyes@mail.ustc.edu.cn,
	netdev@vger.kernel.org
To: junchangwang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43061
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754475Ab0KHUTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 15:19:30 -0500
In-Reply-To: <20101108091941.GB5025@Desktop-Junchang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Junchang Wang <junchangwang@gmail.com>
Date: Mon, 8 Nov 2010 17:19:43 +0800

> 
> This fix a bug reported by backyes.
> Right the first time pktgen's using queue_map that's not been initialized
> by set_cur_queue_map(pkt_dev);
> 
> Signed-off-by: Junchang Wang <junchangwang@gmail.com>
> Signed-off-by: Backyes <backyes@mail.ustc.edu.cn>

Applied, thank you.

I think I added this bug :-)

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Avoid transmits during sky2_down()
Date: Sun, 02 Aug 2009 13:09:12 -0700 (PDT)
Message-ID: <20090802.130912.180264634.davem@davemloft.net>
References: <392fb48f0907310457t15d8f9bbmdf77f062c423a475@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: mikem@ring3k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50963
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753632AbZHBUJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 16:09:04 -0400
In-Reply-To: <392fb48f0907310457t15d8f9bbmdf77f062c423a475@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>
Date: Fri, 31 Jul 2009 20:57:42 +0900

> I am aware you object to storing extra state, but I can't see a way
> around this. Without remembering that we're restarting,
> netif_wake_queue() is called in the ISR from sky2_tx_complete(), and
> netif_tx_lock() is used in sky2_tx_done().  If anybody can see a way
> around this, please let me know.

Stephen please do something about this, soon.

Michael has been trying to get this fixed for more than a month, and
if you don't have a better fix like right now then we should put his
fix in for the time being.

Sky2 patches are ones that consistently rot in patchwork and I'd
appreciate if it that trend would cease, thanks.

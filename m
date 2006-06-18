From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.18 1/3] tg3: Remove unnecessary tx_lock
Date: Sat, 17 Jun 2006 21:57:52 -0700 (PDT)
Message-ID: <20060617.215752.25476828.davem@davemloft.net>
References: <1149536843.13155.6.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36834
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932093AbWFRE5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jun 2006 00:57:54 -0400
To: mchan@broadcom.com
In-Reply-To: <1149536843.13155.6.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 05 Jun 2006 12:47:23 -0700

> Remove tx_lock where it is unnecessary. tg3 runs lockless and so it
> requires interrupts to be disabled and sync'ed, netif_queue and NAPI
> poll to be stopped before the device can be reconfigured. After
> stopping everything, it is no longer necessary to get the tx_lock.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.

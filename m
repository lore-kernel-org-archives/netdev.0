From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] NET: sungem, use spin_trylock_irqsave
Date: Tue, 14 Jul 2009 14:10:20 -0700 (PDT)
Message-ID: <20090714.141020.34896663.davem@davemloft.net>
References: <1247520220-31960-1-git-send-email-jirislaby@gmail.com>
	<1247520220-31960-2-git-send-email-jirislaby@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jirislaby@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42073
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755520AbZGNVKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 17:10:16 -0400
In-Reply-To: <1247520220-31960-2-git-send-email-jirislaby@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jirislaby@gmail.com>
Date: Mon, 13 Jul 2009 23:23:40 +0200

> -	if (!spin_trylock(&gp->tx_lock)) {
> +	if (!spin_trylock_irqsave(&gp->tx_lock)) {

I'm about to give you a royal flaming.

Any idea why?

(hint: type 'make' before you send patches!!!!)


From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] asix: fix setting custom MAC address on Asix 88772
 devices
Date: Tue, 10 Jan 2012 15:00:04 -0800 (PST)
Message-ID: <20120110.150004.868770279947981269.davem@davemloft.net>
References: <20120110164017.24658.9965.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grundler@chromium.org, allan@asix.com.tw
To: jussi.kivilinna@mbnet.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46990 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933809Ab2AJXAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 18:00:20 -0500
In-Reply-To: <20120110164017.24658.9965.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Date: Tue, 10 Jan 2012 18:40:17 +0200

> In kernel v3.2 initialization sequence for Asix 88772 devices was changed so
> that hardware is reseted on every time interface is brought up (ifconfig up),
> instead just at USB probe time. This causes problem with setting custom MAC
> address to device as ax88772_reset causes reload of MAC address from EEPROM.
> 
> This patch fixes the issue by rewriting MAC address at end of ax88772_reset.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> Acked-by: Grant Grundler <grundler@chromium.org>

Applied.

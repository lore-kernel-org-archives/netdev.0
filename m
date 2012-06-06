From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Net: mv643xx_eth: Fix compile error for architectures
 without clk.
Date: Wed, 06 Jun 2012 10:38:55 -0700 (PDT)
Message-ID: <20120606.103855.1760953957346622701.davem@davemloft.net>
References: <1339000843-26078-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jwboyer@redhat.com, buytenh@wantstofly.org, olof@lixom.net,
	netdev@vger.kernel.org, ben@decadent.org.uk
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756059Ab2FFRiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 13:38:55 -0400
In-Reply-To: <1339000843-26078-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed,  6 Jun 2012 18:40:43 +0200

> Commit 452503ebc (ARM: Orion: Eth: Add clk/clkdev support.) broke
> the building of the driver on architectures which don't have clk
> support. In particular PPC32 Pegasos which uses this driver.
> 
> Add #ifdef around the clk API usage.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks.

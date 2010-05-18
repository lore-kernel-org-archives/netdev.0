From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dm9000: fix "BUG: spinlock recursion"
Date: Mon, 17 May 2010 22:48:43 -0700 (PDT)
Message-ID: <20100517.224843.90787234.davem@davemloft.net>
References: <1274004407-12323-1-git-send-email-baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, s.hauer@pengutronix.de,
	ben-linux@fluff.org
To: baruch@tkos.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43880
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755144Ab0ERFse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:48:34 -0400
In-Reply-To: <1274004407-12323-1-git-send-email-baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baruch Siach <baruch@tkos.co.il>
Date: Sun, 16 May 2010 13:06:47 +0300

> dm9000_set_rx_csum and dm9000_hash_table are called from atomic context (in
> dm9000_init_dm9000), and from non-atomic context (via ethtool_ops and
> net_device_ops respectively). This causes a spinlock recursion BUG. Fix this by
> renaming these functions to *_unlocked for the atomic context, and make the
> original functions locking wrappers for use in the non-atomic context.
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>

Applied.

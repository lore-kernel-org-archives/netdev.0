From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 V2] tg3: Fix phylib locking strategy
Date: Wed, 07 Oct 2009 03:41:41 -0700 (PDT)
Message-ID: <20091007.034141.80564057.davem@davemloft.net>
References: <1254801692.18507@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: felix@embedded-sol.com, netdev@vger.kernel.org, mchan@broadcom.com,
	andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45410
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757509AbZJGKlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 06:41:46 -0400
In-Reply-To: <1254801692.18507@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 5 Oct 2009 20:55:29 -0700

> O.K.  Here is the latest version.  Felix, can you verify your problem
> is solved with this patch?
> 
> ---
> 
> Felix Radensky noted that chip resets were generating stack trace dumps.
> This is because the driver is attempting to acquire the mdio bus mutex
> while holding the tp->lock spinlock.  The fix is to change the code such
> that every phy access takes the tp->lock spinlock instead.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>

I'm going to apply this now to net-2.6, let me know if there are
any updates after testing.

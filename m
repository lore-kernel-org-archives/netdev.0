From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4][TG3]: Fix race condition when calling
 register_netdev().
Date: Sun, 17 Dec 2006 17:07:43 -0800 (PST)
Message-ID: <20061217.170743.122943075.davem@davemloft.net>
References: <1166251723.30429.10.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57413
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753336AbWLRBHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Dec 2006 20:07:43 -0500
To: mchan@broadcom.com
In-Reply-To: <1166251723.30429.10.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 15 Dec 2006 22:48:43 -0800

> [TG3]: Fix race condition when calling register_netdev().
> 
> Hot-plug scripts can call tg3_open() as soon as register_netdev() is
> called in tg3_init_one().  We need to call pci_set_drvdata() before
> register_netdev(), and netif_carrier_off() needs to be moved to
> tg3_open() to avoid race conditions.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Another excellent catch, patch applied, thanks Michael.

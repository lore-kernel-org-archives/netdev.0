From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: fix early spinlock use
Date: Thu, 09 Oct 2008 14:36:11 -0700 (PDT)
Message-ID: <20081009.143611.182113876.davem@davemloft.net>
References: <20081009201607.GA20030@electric-eye.fr.zoreil.com>
	<20081009.142807.229045310.davem@davemloft.net>
	<20081009213513.GB19429@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ivecera@redhat.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47454
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755228AbYJIVgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 17:36:35 -0400
In-Reply-To: <20081009213513.GB19429@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 9 Oct 2008 23:35:13 +0200

> rtl8169_init_one
> -> rtl_init_mac_address
>    -> rtl_rar_set
>       -> spin_lock_irq(&tp->lock);
> [...]
> -> spin_lock_init(&tp->lock);
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Applied thanks!

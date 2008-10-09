From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: read MAC address from EEPROM on init
Date: Thu, 9 Oct 2008 22:16:07 +0200
Message-ID: <20081009201607.GA20030@electric-eye.fr.zoreil.com>
References: <20081008.154131.141753610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ivecera@redhat.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:32796 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752309AbYJIUQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 16:16:26 -0400
Content-Disposition: inline
In-Reply-To: <20081008.154131.141753610.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
> 
> Applied to net-next-2.6

rtl8169_init_one
-> rtl_init_mac_address
   -> rtl_rar_set
      -> spin_lock_irq(&tp->lock);
[...]
-> spin_lock_init(&tp->lock);

I am used to respin my patch kit anyway.

-- 
Ueimor

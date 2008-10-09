From: David Miller <davem@davemloft.net>
Subject: Re: r8169: read MAC address from EEPROM on init
Date: Thu, 09 Oct 2008 14:28:07 -0700 (PDT)
Message-ID: <20081009.142807.229045310.davem@davemloft.net>
References: <20081008.154131.141753610.davem@davemloft.net>
	<20081009201607.GA20030@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ivecera@redhat.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42119
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753353AbYJIV2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 17:28:31 -0400
In-Reply-To: <20081009201607.GA20030@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 9 Oct 2008 22:16:07 +0200

> David Miller <davem@davemloft.net> :
> > 
> > Applied to net-next-2.6
> 
> rtl8169_init_one
> -> rtl_init_mac_address
>    -> rtl_rar_set
>       -> spin_lock_irq(&tp->lock);
> [...]
> -> spin_lock_init(&tp->lock);

Grrr...

> I am used to respin my patch kit anyway.

Please send it to me, I'd _REALLY_ appreciate this as the
only patches in the queue were posted by other people and
you're only mention or r8169 changes is you posting a pointer
to some GIT tree or patch set without any "dave/jeff please
pull this".

I'd rather you send me fixes as soon as you have them rather
than have them get clogged up in your tree for weeks or longer.
That's how mistakes like this happen.

If I don't have any fixes from the official person (you) then
I'm going to apply fixes that look OK from people who do actually
post them individually to the list for review.

:-)

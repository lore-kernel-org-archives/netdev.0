From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8139 driver (8139too.c) TX Timeout doesn't allow interrupt handler to disable receive interrupts at high bi-directional traffic
Date: Thu, 30 Nov 2006 01:25:55 +0100
Message-ID: <20061130002554.GE18057@electric-eye.fr.zoreil.com>
References: <010C7BAE6783F34D9AC336EE5A01A08802D2D762@dbde01.ent.ti.com> <20061129122444.0614cf56@freekitty> <20061129224400.GC18057@electric-eye.fr.zoreil.com> <20061129145054.741ad7c5@freekitty> <20061129233219.GD18057@electric-eye.fr.zoreil.com> <20061129160906.695b4d03@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Basheer, Mansoor Ahamed" <mansoor.ahamed@ti.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:63381 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S967721AbWK3A1K
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 19:27:10 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061129160906.695b4d03@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
[...]
> Move the poll_enable to after hw_start() or put it inside hw_start.

"after" probably The order would be the opposite of the one used
in rtl8139_poll (which does __netif_rx_complete then irq_unlock)
and it's past 1 AM. It starts to be a bit foggy.

-- 
Ueimor

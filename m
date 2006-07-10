From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [VLAN]: translate IF_OPER_DORMANT to netif_dormant_on()
Date: Mon, 10 Jul 2006 23:58:28 +0200
Message-ID: <200607102358.28470.stefan@loplof.de>
References: <44AE2FCC.6020207@trash.net> <200607100817.26635.stefan@loplof.de> <m33bd9653d.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from natreg.rzone.de ([81.169.145.183]:28309 "EHLO natreg.rzone.de")
	by vger.kernel.org with ESMTP id S965022AbWGJV7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 17:59:14 -0400
To: Krzysztof Halasa <khc@pm.waw.pl>
In-Reply-To: <m33bd9653d.fsf@defiant.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, 10. Juli 2006 14:01 schrieb Krzysztof Halasa:

> > You've got two independant flags of which one does not stop the queue.
>
> Is it ok to set that flag without synchronization with other flags?
> I.e, from within another module and without using cross-module locks,
> as I've shown at the time? Just asking, I don't know what the final
> conclusion was.
>
> I.e., is it ok if the hardware module does netif_carrier_on/off()
> (for example, from its IRQ handler) and if the protocol module does
> netif_dormant_on/off() independently (for example, from its timer
> or linkwatch)?

Yes, you can read and write these flags independantly. For the details, look 
at Documentation/networking/operstates.txt in the 2.6.17 tree.

Stefan

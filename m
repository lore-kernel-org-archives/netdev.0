From: Stephen Hemminger <shemminger@osdl.org>
Subject: Dlink PCI/PCMCIA  id conflicts
Date: Wed, 30 Aug 2006 15:37:38 -0700
Message-ID: <20060830153738.0bc23c98@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:32142 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932217AbWH3WlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 18:41:02 -0400
To: Thomas =?UTF-8?B?Qm9nZW5kw7ZyZmVy?= <tsbogend@alpha.franken.de>,
	Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It appears that the Dlink DGE-550SX card has this pci_id:
	vendor = 0x1186, device = 0x4001
(decoded from SysKonnect version of sk98lin driver).

According to a couple of places Dlink also uses the same id for the DFE-650TX
card.  Before I add this to the sky2 driver, I want to make sure not to break
existing users of the other card. 

Does the pcmcia code end up overlapping the pci on this?

Alternatively, we need to use the version id to disambiguate which was
done already for another Dlink card.  That would mean finding people with
all the versions of the cards to decode what to put in the table (yuck).


-- 
Stephen Hemminger <shemminger@osdl.org>

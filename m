From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 09/12] r8169: MSI support
Date: Tue, 08 May 2007 00:53:23 -0400
Message-ID: <46400243.9000802@garzik.org>
References: <20070426205714.GA12701@electric-eye.fr.zoreil.com> <20070426214907.GJ7344@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bernhard Walle <bernhard.walle@gmx.de>,
	Edward Hsu <edward_hsu@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54117 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967792AbXEHEx0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 00:53:26 -0400
In-Reply-To: <20070426214907.GJ7344@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> It is currently limited to 0x8136 and 0x8168. 8169sb/8110sb ought to
> handle it as well where they support MSI.
> 
> Includes unregister_netdev() fix from Bernhard Walle <bwalle@suse.de>
> against BUG_ON(irq_has_action(dev->first_msi_irq)) (2007/02/24).
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Fixed-by: Bernhard Walle <bernhard.walle@gmx.de>
> Cc: Edward Hsu <edward_hsu@realtek.com>
> ---
>  drivers/net/r8169.c |  102 ++++++++++++++++++++++++++++++++++++++++++++++++--
>  1 files changed, 97 insertions(+), 5 deletions(-)

PCI MSI is increasingly mature upstream, so I do not wish to add more 
IRQ handling test code to each individual driver.

Just add the MSI support without the test interrupt stuff.

	Jeff




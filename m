From: Mike Rapoport <mike@compulab.co.il>
Subject: Re: smsc9220 with omap3
Date: Wed, 24 Jun 2009 17:52:16 +0300
Message-ID: <4A423DA0.6010306@compulab.co.il>
References: <4A40FE32.1030708@compulab.co.il> <20090623222928.GM29236@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org,
	ARM Linux <linux-arm-kernel@lists.arm.linux.org.uk>
To: Daniel Mack <daniel@caiaq.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from legaljet.webserversystems.com ([67.18.134.218]:46049 "EHLO
	compulab.site5.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753585AbZFXOwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 10:52:36 -0400
In-Reply-To: <20090623222928.GM29236@buzzloop.caiaq.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Daniel Mack wrote:
> On Tue, Jun 23, 2009 at 07:09:22PM +0300, Mike Rapoport wrote:
>> I'm trying to enable smsc9220 chip with OMAP3EVM board. Till now I was able to
>> get as far as "eth1: smsc911x_mii_probe: Failed Loop Back Test" error message
>> after a bunch of "eth1: smsc911x_phy_check_loopbackpkt: Failed to transmit
>> during loopback test".
>> Does anybody have a clue what's going wrong?
> 
> We're using that chip connected to a PXA300 and it works well, so I
> wouldn't suspect the driver. Does it work from any other scenario like
> the bootloader? And I don't know OMAP, but it might be helpful to others
> if you posted your platform_data config.

The platform_data I use is:
static struct smsc911x_platform_config smsc911x_config = {
	.irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
	.irq_type = SMSC911X_IRQ_TYPE_PUSH_PULL,
	.flags = SMSC911X_USE_32BIT | SMSC911X_FORCE_INTERNAL_PHY,
};

The chip is properly detected, and if I tweak the loopback test to return 0, the
 driver does not complain any more. Moreover, it seems that RX work, at least
ifconfig reports non-zero values for RX packets. Still, there is no even single
packet transmitted from the smsc9220 :(
I suspect that there's some problem with the hardware, and probably someone
encountered similar problems and may have found a solution.

> Daniel
> 

-- 
Sincerely yours,
Mike.


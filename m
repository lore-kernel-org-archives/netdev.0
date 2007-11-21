From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 8/8] ibm_newemac: Skip EMACs that are marked unused by
	the firmware
Date: Wed, 21 Nov 2007 18:28:09 +1100
Message-ID: <1195630089.6970.62.camel@pasglop>
References: <20071121060737.6AA72DDE0C@ozlabs.org>
	 <200711210813.51525.sr@denx.de>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, jgarzik@pobox.com, netdev@vger.kernel.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:45130 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750765AbXKUH20 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 02:28:26 -0500
In-Reply-To: <200711210813.51525.sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2007-11-21 at 08:13 +0100, Stefan Roese wrote:
> On Wednesday 21 November 2007, Benjamin Herrenschmidt wrote:
> > From: Hugh Blemings <hugh@blemings.org>
> >
> > Depending on how the 44x processors are wired, some EMAC cells
> > might not be useable (and not connected to a PHY). However, some
> > device-trees may choose to still expose them (since their registers
> > are present in the MMIO space) but with an "unused" property in them.
> >
> > Signed-off-by: Hugh Blemings <hugh@blemings.org>
> > Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> 
> Acked-by: Stefan Roese <sr@denx.de>

I noticed that I forgot to add your Ack's to the patches. I'll do so
before I ask Paul to pull them.

Thanks !

Ben.



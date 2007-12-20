From: Ben Dooks <ben@fluff.org>
Subject: Re: DM9000_IRQ_FLAGS
Date: Thu, 20 Dec 2007 09:45:25 +0000
Message-ID: <20071220094524.GA9216@fluff.org.uk>
References: <20071211191823.GD15295@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Daniel Mack <daniel@caiaq.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:49323 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754949AbXLTJpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 04:45:32 -0500
Content-Disposition: inline
In-Reply-To: <20071211191823.GD15295@buzzloop.caiaq.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 11, 2007 at 08:18:23PM +0100, Daniel Mack wrote:
> Hi,
> 
> on Toradex' Colibri, a PXA270 based board with a DM9000 ethernet
> controller, this driver won't work due to unsuitable DM9000_IRQ_FLAGS.
> If I understood the code behind request_irq() correctly, it's not
> recommended to register an IRQ without any of the IRQT_* flags set.
> 
> Is there any concerns about applying the patch below?

Yes, that will possibly break all systems using level-triggered
interrupts.

Probably the best solution is to pass the data via the platform
information being fed to the device.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'

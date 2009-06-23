From: Daniel Mack <daniel@caiaq.de>
Subject: Re: smsc9220 with omap3
Date: Wed, 24 Jun 2009 00:29:28 +0200
Message-ID: <20090623222928.GM29236@buzzloop.caiaq.de>
References: <4A40FE32.1030708@compulab.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org,
	ARM Linux <linux-arm-kernel@lists.arm.linux.org.uk>
To: Mike Rapoport <mike@compulab.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:60194 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752893AbZFWW3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 18:29:30 -0400
Content-Disposition: inline
In-Reply-To: <4A40FE32.1030708@compulab.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 23, 2009 at 07:09:22PM +0300, Mike Rapoport wrote:
> I'm trying to enable smsc9220 chip with OMAP3EVM board. Till now I was able to
> get as far as "eth1: smsc911x_mii_probe: Failed Loop Back Test" error message
> after a bunch of "eth1: smsc911x_phy_check_loopbackpkt: Failed to transmit
> during loopback test".
> Does anybody have a clue what's going wrong?

We're using that chip connected to a PXA300 and it works well, so I
wouldn't suspect the driver. Does it work from any other scenario like
the bootloader? And I don't know OMAP, but it might be helpful to others
if you posted your platform_data config.

Daniel

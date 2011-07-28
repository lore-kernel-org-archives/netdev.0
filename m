From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8139 Flow Control?
Date: Thu, 28 Jul 2011 08:35:26 +0200
Message-ID: <20110728063526.GA11214@electric-eye.fr.zoreil.com>
References: <4E2DC710.5000100@anduras.de> <4E3004BD.4090705@anduras.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, jgarzik@pobox.com
To: Sven Anders <anders@anduras.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38108 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197Ab1G1GvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 02:51:17 -0400
Content-Disposition: inline
In-Reply-To: <4E3004BD.4090705@anduras.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sven Anders <anders@anduras.de> :
> Sven Anders wrote:
[...]
> > We have appliances with Realtek 8139C/8139C+ (rev 10) chipsets (with the
> > PCI IDs: 10ec:8139). We are using the 8139too driver (version: 0.9.28)

The PCI revision ID is not incompatible with a 8139c(l)+. If so the 8139cp
driver may prove easier to handle at the driver programming level. It's
almost surely less commonly used though.

I'd suggest to use both PCI information and TxConfig content to identify
Realtek's chipset. ethtool should provide the latter.

> > According the datasheet the chipset supports Flow Control (IEEE 802.3x).
> > 
> > I want to know, if the support for enabling flow control is missing in
> > the driver by purpose or is only not implemented due to lack of time?
[...]
> Can somebody of the old implementors please answer this question?

Hint ? :o)

This hardware is not exactly fun, especially if you do not own a c+ model
(4 Tx descriptors, a single copy-only receive buffer, really cheap...).

> We need that feature and I'm willing to implement it, but I need the
> confirmation, that it was not done due to lack of time and not because
> will not work (correctly)...

If you do not get an answer and the relevant bit is already set in the
eeprom, you should be able to make your own mind shortly. The comment
in the datasheet rightfully reminds that both the NIC and the peer
networking gear need to handle flow control correctly.

Good luck.

-- 
Ueimor

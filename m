From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 4/9] pasemi_mac: Use MMIO instead of pci config accessors
Date: Mon, 02 Jul 2007 08:37:08 -0400
Message-ID: <4688F174.4000308@pobox.com>
References: <20070622194720.614405000@lixom.net> <20070622200526.GE11723@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51104 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751730AbXGBMhL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 08:37:11 -0400
In-Reply-To: <20070622200526.GE11723@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> Move away from using the pci config access functions for simple register
> access.  Our device has all of the registers in the config space (hey,
> from the hardware point of view it looks reasonable :-), so we need to
> somehow get to it. Newer firmwares have it in the device tree such that
> we can just get it and ioremap it there (in case it ever moves in future
> products). For now, provide a hardcoded fallback for older firmwares.
> 
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

patches 4-9 seen sane.  dropped due to previous patches being dropped



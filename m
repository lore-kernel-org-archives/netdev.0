From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 3/6] [TULIP]  fix for Lite-On 82c168 PNIC
Date: Thu, 15 Mar 2007 11:21:04 -0400
Message-ID: <45F96460.8020804@garzik.org>
References: <20070312093128.577087000@linux.intel.com> <20070312184217.818534000@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org,
	Guido Classen <classeng@clagi.de>,
	Grant Grundler <grundler@parisc-linux.org>
To: Valerie Henson <val_henson@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50360 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422890AbXCOPVI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 11:21:08 -0400
In-Reply-To: <20070312184217.818534000@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Valerie Henson wrote:
> From: Guido Classen <classeng@clagi.de>
> 
> This small patch fixes two issues with the Lite-On 82c168 PNIC adapters.
> I've tested it with two cards in different machines both chip rev 17
> 
> The first is the wrong register address CSR6 for writing the MII register
> which instead is 0xB8 (this may get a symbol too?) (see similar exisiting code
> at line 437) in tulip_core.c
> 
> [Double-checked by Val Henson; yes, 0xB8 is correct register for
> autonegotiate on this card.]
> 
> At least by my cards, the the bit 31 from the MII register seems to be
> somewhat unstable. This results in reading wrong values from the Phy-Registers
> und prevents the card from correct initialization. I've added a litte delay
> and an second test of the bit. If the bit is stil cleared the read/write
> process has definitely finished.
> 
> [Original patch slightly massaged by Val Henson]
> 
> Signed-off-by: Val Henson <val_henson@linux.intel.com>
> Cc: Guido Classen <classeng@clagi.de>
> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
> Cc: Jeff Garzik <jeff@garzik.org>
> 
> ---
>  drivers/net/tulip/media.c      |   31 +++++++++++++++++++++++++++----
>  drivers/net/tulip/tulip_core.c |    4 ++--
>  2 files changed, 29 insertions(+), 6 deletions(-)

Seems sane, but now on HOLD while it's being discussed



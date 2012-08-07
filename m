From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3 3/7] mv643xx.c: Add basic device tree support.
Date: Tue, 7 Aug 2012 14:56:41 +0000
Message-ID: <201208071456.41412.arnd@arndb.de>
References: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk> <1344350092-24050-4-git-send-email-ian.molton@codethink.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, andrew@lunn.ch,
	thomas.petazzoni@free-electrons.com, ben.dooks@codethink.co.uk,
	netdev@vger.kernel.org
To: Ian Molton <ian.molton@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:60588 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698Ab2HGO4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 10:56:46 -0400
In-Reply-To: <1344350092-24050-4-git-send-email-ian.molton@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 07 August 2012, Ian Molton wrote:
>     This patch adds basic device tree support to the mv643xx ethernet driver.
> 
>     It should be enough for most current users of the device, and should allow
>     a painless migration.
> 
>     Signed-off-by: Ian Molton <ian.molton@codethink.co.uk>
> ---
>  Documentation/devicetree/bindings/net/mv643xx.txt |   75 +++++++++++++++++
>  drivers/net/ethernet/marvell/mv643xx_eth.c        |   93 +++++++++++++++++++--
>  2 files changed, 161 insertions(+), 7 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/mv643xx.txt

Hi Ian,

Have you had a look at Documentation/devicetree/bindings/marvell.txt ?

I think it documents some of the same thing, so it would be good
to keep all of that in one place. We might also want to move
some of the code from arch/powerpc/sysdev/mv64x60_dev.c
to live in the same place as the device driver.

	Arnd

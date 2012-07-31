From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 1/6] Initial csb1724 board support (FDT)
Date: Tue, 31 Jul 2012 18:43:35 +0200
Message-ID: <20120731164335.GC28852@lunn.ch>
References: <1343749529-17571-1-git-send-email-ian.molton@codethink.co.uk>
 <1343749529-17571-2-git-send-email-ian.molton@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, andrew@lunn.ch,
	thomas.petazzoni@free-electrons.com, ben.dooks@codethink.co.uk,
	arnd@arndb.de, netdev@vger.kernel.org
To: Ian Molton <ian.molton@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from londo.lunn.ch ([80.238.139.98]:42981 "EHLO londo.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755757Ab2GaQou (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2012 12:44:50 -0400
Content-Disposition: inline
In-Reply-To: <1343749529-17571-2-git-send-email-ian.molton@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 31, 2012 at 04:45:24PM +0100, Ian Molton wrote:
> This patch adds support for the csb1724 SoM.
> 
> It includes serial and SATA support.
> 
> Signed-off-by: Ian Molton <ian.molton@codethink.co.uk>
> ---
>  arch/arm/boot/dts/kirkwood-csb1724.dts |   30 ++++++++++++++++
>  arch/arm/configs/csb1724_defconfig     |   47 +++++++++++++++++++++++++

I'm unlikely to accept csb1724_defconfig. Please keep it for yourself.
If there is anything you want adding to kirkwood_defconfig, please let
me know.

Jason planned to rework kirkwood_defconfig, but he got sidetracked. I
hope we can get to this soon and enable the building of all DT
platforms by default.

	  Andrew

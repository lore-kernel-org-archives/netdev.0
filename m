From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: MIPSsim: Fix modpost warning.
Date: Mon, 21 Jun 2010 13:40:36 -0700 (PDT)
Message-ID: <20100621.134036.71123880.davem@davemloft.net>
References: <20100621134450.GA10265@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38055
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758458Ab0FUUkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 16:40:24 -0400
In-Reply-To: <20100621134450.GA10265@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ralf Baechle <ralf@linux-mips.org>
Date: Mon, 21 Jun 2010 14:44:50 +0100

> $ make CONFIG_DEBUG_SECTION_MISMATCH=y
> [...]
> WARNING: drivers/net/built-in.o(.data+0x0): Section mismatch in reference from the variable mipsnet_driver to the function .init.text:mipsnet_probe()
> The variable mipsnet_driver references
> the function __init mipsnet_probe()
> If the reference is valid then annotate the
> variable with __init* or __refdata (see linux/init.h) or name the variable:
> *_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,
> [...]
> 
> Fixed by making mipsnet_probe __devinit.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks Ralf.

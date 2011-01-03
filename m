From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc-ircc2: Fix section mismatch derived from
 smsc_ircc_pnp_driver variable
Date: Mon, 03 Jan 2011 11:53:19 -0800 (PST)
Message-ID: <20110103.115319.245401044.davem@davemloft.net>
References: <1294021724-30337-1-git-send-email-sedat.dilek@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sedat.dilek@gmail.com
To: sedat.dilek@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294021724-30337-1-git-send-email-sedat.dilek@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sedat Dilek <sedat.dilek@googlemail.com>
Date: Mon,  3 Jan 2011 03:28:44 +0100

>>From my build.log:
> 
> drivers/net/irda/smsc-ircc2.o(.data+0x18): Section mismatch in reference from the variable smsc_ircc_pnp_driver to the function .init.text:smsc_ircc_pnp_probe()
> The variable smsc_ircc_pnp_driver references
> the function __init smsc_ircc_pnp_probe()
> If the reference is valid then annotate the
> variable with __init* or __refdata (see linux/init.h) or name the variable:
> *_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,
> 
> This patch fixes the warning.
> 
> Tested with linux-next (next-20101231)
> 
> Signed-off-by: Sedat Dilek <sedat.dilek@gmail.com>

Just like your other patch, this fix is not correct.

Mark smsc_ircc_pbp_probe() as __devinit instead of __init to fix
this bug.

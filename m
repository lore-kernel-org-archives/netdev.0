From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 1/1] drivers: net: cpsw: Fix TX_IN_SEL offset
Date: Fri, 14 Nov 2014 23:53:36 +0530
Message-ID: <546648A8.1000102@ti.com>
References: <87sihlj11v.fsf@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <balbi@ti.com>, <george.cherian@ti.com>,
	<jhovold@gmail.com>, <mpa@pengutronix.de>,
	<bhutchings@solarflare.com>, <zonque@gmail.com>,
	<tklauser@distanz.ch>, <netdev@vger.kernel.org>
To: John Ogness <john.ogness@linutronix.de>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87sihlj11v.fsf@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 14 November 2014 08:12 PM, John Ogness wrote:
> The TX_IN_SEL offset for the CPSW_PORT/TX_IN_CTL register was
> incorrect. This caused the Dual MAC mode to never get set when
> it should. It also caused possible unintentional setting of a
> bit in the CPSW_PORT/TX_BLKS_REM register.
> 
> The purpose of setting the Dual MAC mode for this register is to:
> 
>     "... allow packets from both ethernet ports to be written into
>      the FIFO without one port starving the other port."
> 					- AM335x ARM TRM
> 
> Signed-off-by: John Ogness <john.ogness@linutronix.de>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N

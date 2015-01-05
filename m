From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 linux-next] hp100: simplify hp100_module_init
Date: Sun, 04 Jan 2015 22:23:13 -0500 (EST)
Message-ID: <20150104.222313.844590125087915248.davem@davemloft.net>
References: <1420292656-14429-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, perex@perex.cz,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420292656-14429-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Sat,  3 Jan 2015 14:44:16 +0100

> -Avoid double goto and directly return err where possible.
> -Remove unused labels which fixes:
> 
> drivers/net/ethernet/hp/hp100.c:3047:2: warning: label
> 'out3' defined but not used [-Wunused-label]
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
> This is untested.

Having a sole lone return statement that all flows of control
branch to makes the code easier to audit, than to have a huge
block where each return statement has to be audited independently
for potential cleanups.

Added to the fact that this patch is completely untested, I'm
not applying this, sorry.

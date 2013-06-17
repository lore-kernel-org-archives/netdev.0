From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: Fix build for MCF5272
Date: Mon, 17 Jun 2013 16:11:51 -0700 (PDT)
Message-ID: <20130617.161151.1327615665309510068.davem@davemloft.net>
References: <1371500179-4733-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Frank.Li@freescale.com, jim_baxter@mentor.com
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371500179-4733-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Mon, 17 Jun 2013 13:16:19 -0700

> Commits 4c09eed9 (net: fec: Enable imx6 enet checksum acceleration) and
> baa70a5c (net: fec: enable pause frame to improve rx prefomance for 1G
> network) introduced functionality into the FEC driver which is not
> supported on MCF5272. As result, building images for MCF5272 fails,
> complaining about several undefined symbols.
> 
> Disabled the added functionality for MCF5272 builds.
> 
> Cc: Frank Li <Frank.Li@freescale.com>
> Cc: Jim Baxter <jim_baxter@mentor.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
> Sorry for the added ifdefs. If anyone has a better idea on how to fix
> the problems, let me know.
> 
> This problem exists in 3.9 as well.

Does the M5272 not have these registers, or have you simply not added
defines for where there offsets are in that silicon instance?

I'd much rather you add the register offset defines than pepper the
entire driver with ifdefs.

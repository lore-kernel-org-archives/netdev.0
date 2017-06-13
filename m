From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-rhine: add support for changing MTU
Date: Tue, 13 Jun 2017 17:33:18 -0400 (EDT)
Message-ID: <20170613.173318.167061176274123943.davem@davemloft.net>
References: <149737430797.28477.9215445312169809396.sendpatchset@little-apple>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: magnus.damm@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149737430797.28477.9215445312169809396.sendpatchset@little-apple>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Magnus Damm <magnus.damm@gmail.com>
Date: Wed, 14 Jun 2017 02:18:27 +0900

> From: Magnus Damm <damm+renesas@opensource.se>
> 
> Allow adjusting the MTU for via-rhine devices in case of no TX alignment
> buffer is used.
> 
> Lightly tested on ALIX2D13 hardware by making use of VXLAN with MTU set
> to 1500 on top of via-rhine devices with 1550 MTU. Without this patch
> the VXLAN MTU is limited to less than 1500.
> 
> Signed-off-by: Magnus Damm <damm+renesas@opensource.se>

Why is the TX alignment buffer such an obstacle?

It would be so much nicer if this could be supported for all chip
variants instead of some certain subset which users have no idea
of figuring out.  It's a really bad user experience to set them
up for failure like this.

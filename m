From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] net: atarilance: Remove obsolete IRQ_TYPE_PRIO
Date: Mon, 12 Jan 2015 12:56:57 -0500 (EST)
Message-ID: <20150112.125657.1106579867206771114.davem@davemloft.net>
References: <1421052021-12560-1-git-send-email-geert@linux-m68k.org>
	<1421052021-12560-2-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, perex@perex.cz,
	tiwai@suse.de, linux-m68k@lists.linux-m68k.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421052021-12560-2-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 12 Jan 2015 09:40:17 +0100

> IRQ_TYPE_PRIO is no longer used by the Atari platform interrupt code
> since commit 734085651c9b80aa ("[PATCH] m68k: convert atari irq code")
> in v2.6.18-rc1, so drop it.
> 
> Note that its value has been reused for a different purpose
> (IRQ_TYPE_EDGE_FALLING) since commit 6a6de9ef5850d063 ("[PATCH] genirq:
> core") in v2.6.18-rc1.
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Acked-by: David S. Miller <davem@davemloft.net>

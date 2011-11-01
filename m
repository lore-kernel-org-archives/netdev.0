From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ethernet: Move mac89x0.c from apple to cirrus
Date: Tue, 01 Nov 2011 19:33:05 -0400 (EDT)
Message-ID: <20111101.193305.2191680732467562808.davem@davemloft.net>
References: <1319911741-9977-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <1319911741-9977-1-git-send-email-geert@linux-m68k.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Sat, 29 Oct 2011 20:09:01 +0200

> Macintosh CS89x0 based ethernet cards use a Crystal Semiconductor (Now
> Cirrus Logic) CS89x0 chip, so the mac89x0 driver should be in
> drivers/net/ethernet/cirrus instead of drivers/net/ethernet/apple.
> 
> This also fixes a build problem, as the driver needs a header file from the
> cirrus directory:
> 
> drivers/net/ethernet/apple/mac89x0.c:107:20: error: cs89x0.h: No such file or directory
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied, thanks.

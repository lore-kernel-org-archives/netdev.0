From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/hplance: hplance_init() should be __devinit
Date: Mon, 13 Jun 2011 18:33:02 -0400 (EDT)
Message-ID: <20110613.183302.2017485603429002993.davem@davemloft.net>
References: <1307989056-21814-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-m68k@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <1307989056-21814-1-git-send-email-geert@linux-m68k.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 13 Jun 2011 20:17:36 +0200

> WARNING: vmlinux.o(.devinit.text+0x253e): Section mismatch in reference from the function hplance_init_one() to the function .init.text:hplance_init()
> 
> The forward declaration had the correct attribute, but the actual function
> definition hadn't.
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied, thanks.

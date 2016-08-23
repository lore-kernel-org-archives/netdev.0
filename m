From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipconfig: Fix NULL pointer dereference on
 RARP/BOOTP/DHCP timeout
Date: Mon, 22 Aug 2016 21:05:18 -0700 (PDT)
Message-ID: <20160822.210518.2016675181033767934.davem@davemloft.net>
References: <1471870863-29687-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: u.kleine-koenig@pengutronix.de, treding@nvidia.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geert+renesas@glider.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471870863-29687-1-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert+renesas@glider.be>
Date: Mon, 22 Aug 2016 15:01:03 +0200

> If no RARP, BOOTP, or DHCP response is received, ic_dev is never set,
> causing a NULL pointer dereference in ic_close_devs():
> 
>     Sending DHCP requests ...... timed out!
>     Unable to handle kernel NULL pointer dereference at virtual address 00000004
> 
> To fix this, add a check to avoid dereferencing ic_dev if it is still
> NULL.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> Fixes: 2647cffb2bc6fbed ("net: ipconfig: Support using "delayed" DHCP replies")

Applied.

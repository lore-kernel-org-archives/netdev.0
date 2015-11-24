From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4/ipconfig: Rejoin broken lines in console
 output
Date: Tue, 24 Nov 2015 12:00:24 -0500 (EST)
Message-ID: <20151124.120024.1138985637733582287.davem@davemloft.net>
References: <1448370503-16424-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bst@pengutronix.de, joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert+renesas@glider.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448370503-16424-1-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert+renesas@glider.be>
Date: Tue, 24 Nov 2015 14:08:23 +0100

> Commit 09605cc12c078306 ("net ipv4: use preferred log methods") replaced
> a few calls of pr_cont() after a console print without a trailing
> newline by pr_info(), causing lines to be split during IP
> autoconfiguration, like:
> 
>     .
>     ,
>      OK
>     IP-Config: Got DHCP answer from 192.168.97.254,
>     my address is 192.168.97.44
> 
> Convert these back to using pr_cont(), so it prints again:
> 
>     ., OK
>     IP-Config: Got DHCP answer from 192.168.97.254, my address is 192.168.97.44
> 
> Absorb the printing of "my address ..." into the previous call to
> pr_info(), as there's no reason to use a continuation there.
> 
> Convert one more pr_info() to print nameservers while we're at it.
> 
> Fixes: 09605cc12c078306 ("net ipv4: use preferred log methods")
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Applied, thank you.

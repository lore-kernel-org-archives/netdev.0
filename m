From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: meth: Add set_rx_mode hook to fix ICMPv6 neighbor
 discovery
Date: Tue, 27 Dec 2011 10:34:08 -0800
Message-ID: <20111227103408.01aad10e@nehalam.linuxnetplumber.net>
References: <4EED3A3D.9080503@gentoo.org>
        <4EF95247.7000403@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linux MIPS List <linux-mips@linux-mips.org>
To: Joshua Kinard <kumba@gentoo.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <4EF95247.7000403@gentoo.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Dec 2011 00:06:15 -0500
Joshua Kinard <kumba@gentoo.org> wrote:

> @@ -95,7 +95,7 @@ struct mace_video {
>   * Ethernet interface
>   */
>  struct mace_ethernet {
> -	volatile unsigned long mac_ctrl;
> +	volatile u64 mac_ctrl;
>  	volatile unsigned long int_stat;
>  	volatile unsigned long dma_ctrl;
>  	volatile unsigned long timer;


This device driver writer needs to read:
  Documentation/volatile-considered-harmful.txt

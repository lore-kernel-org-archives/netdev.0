From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [2.6 patch] drivers/net/wan/: possible cleanups
Date: Sun, 27 Mar 2005 17:38:38 +0100
Message-ID: <1111941516.14877.325.camel@localhost.localdomain>
References: <20050327143418.GE4285@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050327143418.GE4285@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sul, 2005-03-27 at 15:34, Adrian Bunk wrote:
>   - syncppp.c: sppp_input
>   - syncppp.c: sppp_change_mtu
>   - z85230.c: z8530_dma_sync
>   - z85230.c: z8530_txdma_sync

Please leave the z85230 ones at least. They are an intentional part of
the external API for writing other 85230 card drivers.

Alan

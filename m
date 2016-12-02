From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: altera: TSE: Remove unneeded dma
 sync for tx buffers
Date: Fri, 02 Dec 2016 12:11:41 -0500 (EST)
Message-ID: <20161202.121141.1787238234799478833.davem@davemloft.net>
References: <1480546112-3099-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridger@opensource.altera.com, nios2-dev@lists.rocketboards.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: LinoSanfilippo@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480546112-3099-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Wed, 30 Nov 2016 23:48:31 +0100

> An explicit dma sync for device directly after mapping as well as an
> explicit dma sync for cpu directly before unmapping is unnecessary and
> costly on the hotpath. So remove these calls.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Applied.

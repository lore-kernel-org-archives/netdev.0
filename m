From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] net: adaptec: starfire: add checks for dma mapping
 errors
Date: Mon, 23 Jan 2017 12:53:17 -0500 (EST)
Message-ID: <20170123.125317.799337053139253880.davem@redhat.com>
References: <1484952744-9815-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ionut@badula.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484952744-9815-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat, 21 Jan 2017 01:52:24 +0300

> init_ring() and refill_rx_ring() don't check if mapping dma memory succeed.
> The patch adds the checks and failure handling.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

The transmit side has the same exact problem, can you take care of both
of them at the same time?

Thanks.

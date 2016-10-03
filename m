From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvmdio: do not clk_disable_unprepare() NULL clock
Date: Mon, 03 Oct 2016 02:03:50 -0400 (EDT)
Message-ID: <20161003.020350.1461285284620686116.davem@davemloft.net>
References: <1475272598-6554-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, andrew@lunn.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475272598-6554-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat,  1 Oct 2016 00:56:37 +0300

> There is no need to clk_disable_unprepare(dev->clk)
> before it was initialized.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: lpc_eth: Fix crash on ip link up
Date: Tue, 02 Sep 2014 13:22:17 -0700 (PDT)
Message-ID: <20140902.132217.1247025622945425190.davem@davemloft.net>
References: <1409572006-26876-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: stigge@antcom.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409572006-26876-1-git-send-email-stigge@antcom.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: stigge@antcom.de
Date: Mon,  1 Sep 2014 13:46:46 +0200

> From: Roland Stigge <stigge@antcom.de>
> 
> When a link is already up, the following sequence makes the kernel
> block completely:
> 
>   ip link set dev eth0 down
>   ip link set dev eth0 up
> 
> This is because on suspended phy, the following lines
> 
>   __lpc_eth_reset(pldat);
>   __lpc_eth_init(pldat);
> 
> make the LPC ethernet core block (see LPC32x0 manual). The PHY needs to be
> (re-)activated low-level first.
> 
> Signed-off-by: Roland Stigge <stigge@antcom.de>

Applied, thanks.

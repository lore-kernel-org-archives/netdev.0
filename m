From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: initialize rc to zero to avoid returning
 garbage value
Date: Sat, 13 Aug 2016 15:52:14 -0700 (PDT)
Message-ID: <20160813.155214.2066414782303807467.davem@davemloft.net>
References: <1471033764-7077-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, Raju.Lakkaraju@microsemi.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471033764-7077-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri, 12 Aug 2016 21:29:24 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> In the case where phydev->interrupts is not PHY_INTERRUPT_ENABLED
> function vsc85xx_ack_interrupt is returning an uninitialized
> garbage value.  Fix this by initializing rc to zero.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.

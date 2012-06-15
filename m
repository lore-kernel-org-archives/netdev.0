From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: c_can: precedence error in c_can_chip_config()
Date: Fri, 15 Jun 2012 15:26:23 -0700 (PDT)
Message-ID: <20120615.152623.509401630460869805.davem@davemloft.net>
References: <1339755644-6686-1-git-send-email-mkl@pengutronix.de>
	<1339755644-6686-2-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	dan.carpenter@oracle.com
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1339755644-6686-2-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri, 15 Jun 2012 12:20:44 +0200

> From: Dan Carpenter <dan.carpenter@oracle.com>
> 
> (CAN_CTRLMODE_LISTENONLY & CAN_CTRLMODE_LOOPBACK) is (0x02 & 0x01) which
> is zero so the condition is never true.  The intent here was to test
> that both flags were set.
> 
> Cc: <stable@kernel.org> # 2.6.39+
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>

Applied.

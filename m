From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: pcan_usb: fix wrong memcpy() bytes length
Date: Sun, 11 Aug 2013 21:52:18 -0700 (PDT)
Message-ID: <20130811.215218.820389949622900993.davem@davemloft.net>
References: <1376041446-24058-1-git-send-email-mkl@pengutronix.de>
	<1376041446-24058-2-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
	linux-can@vger.kernel.org, s.grosjean@peak-system.com,
	stable@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1376041446-24058-2-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri,  9 Aug 2013 11:44:06 +0200

> From: Stephane Grosjean <s.grosjean@peak-system.com>
> 
> Fix possibly wrong memcpy() bytes length since some CAN records received from
> PCAN-USB could define a DLC field in range [9..15].
> In that case, the real DLC value MUST be used to move forward the record pointer
> but, only 8 bytes max. MUST be copied into the data field of the struct
> can_frame object of the skb given to the network core.
> 
> Cc: linux-stable <stable@vger.kernel.org>
> Signed-off-by: Stephane Grosjean <s.grosjean@peak-system.com>
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>

Applied, thanks.

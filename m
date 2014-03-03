From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2014-03-03
Date: Mon, 03 Mar 2014 16:05:36 -0500 (EST)
Message-ID: <20140303.160536.1096367885545296290.davem@davemloft.net>
References: <1393854875-8171-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1393854875-8171-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon,  3 Mar 2014 14:54:27 +0100

> this is a pull request of 8 patches. Oliver Hartkopp contributes a patch which
> removes the CAN FD compatibility for CAN 2.0 sockets, as it turns out that this
> compatibility has some conceptual cornercases. The remaining 7 patches are by
> me, they address a problem in the flexcan driver. When shutting down the
> interface ("ifconfig can0 down") under heavy network load the whole system will
> hang. This series reworks the actual sequence in close() and the transition
> from and to the low power modes of the CAN controller.

Pulled, thanks a lot Marc.

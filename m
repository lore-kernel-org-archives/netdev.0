From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2017-06-09
Date: Fri, 09 Jun 2017 15:42:17 -0400 (EDT)
Message-ID: <20170609.154217.1768446080709146205.davem@davemloft.net>
References: <20170609125513.24436-1-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170609125513.24436-1-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri,  9 Jun 2017 14:55:07 +0200

> this is a pull request of 6 patches for net/master.
> 
> There's a patch by Stephane Grosjean that fixes an uninitialized symbol warning
> in the peak_canfd driver. A patch by Johan Hovold to fix the product-id
> endianness in an error message in the the peak_usb driver. A patch by Oliver
> Hartkopp to enable CAN FD for virtual CAN devices by default. Three patches by
> me, one makes the helper function can_change_state() robust to be called with
> cf == NULL. The next patch fixes a memory leak in the gs_usb driver. And the
> last one fixes a lockdep splat by properly initialize the per-net
> can_rcvlists_lock spin_lock.

Pulled, thank you Marc.

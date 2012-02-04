From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] can: driver updates
Date: Sat, 04 Feb 2012 16:44:35 -0500 (EST)
Message-ID: <20120204.164435.967762795248861095.davem@davemloft.net>
References: <1328230318-8962-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev@vger.kernel.org, kernel@pengutronix.de, mkl@blackshift.org,
	linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1328230318-8962-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri,  3 Feb 2012 01:51:49 +0100

> this patch series targets net-next. It consists of various driver updates:
> - plx_pci: add IXXAT PCI card
> - flexcan: fixes CAN specific loopback handling
> - pch_can: updates to copyright and Kconfig desciption
> - ems_usb: improve memory handling
> - add missing do_get_berr_counter to drivers
> - replace the dev_dbg/info/err/... with the new netdev_xxx
> 
> The last patch (replace the dev_dbg/info/err) depends on a patch I requested
> to go into 3.3 (f84cbda can: ems_usb: Removed double netif_device_detach).
> In order to avoid merge conflicts I added this patch to this series, too.
> If this is a bad idea we can postpone this pull request until you merged
> the net/master branch and I'll respin the pull request without that patch.

Pulled.

Next time I'd rather you simply tell me you have a dependency on some
'net' tree changes for some net-next stuff you'd like to submit, and
then you setup your tree and make your submission when I pull 'net'
into 'net-next' for you.

Putting the change into two trees looks like ass, and results in ugly
and totally unnecessary merges.

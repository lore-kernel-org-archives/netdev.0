From: Damien Riegel <damien.riegel@savoirfairelinux.com>
Subject: Re: [PATCH v6 3/3] can: sja1000: of: add compatibility with
 Technologic Systems version
Date: Thu, 21 Jan 2016 10:28:21 -0500
Message-ID: <20160121152820.GA6523@localhost>
References: <1453304611-31207-1-git-send-email-mkl@pengutronix.de>
 <1453304611-31207-4-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40154 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758925AbcAUPha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 10:37:30 -0500
Content-Disposition: inline
In-Reply-To: <1453304611-31207-4-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marc,


I tested the new technologic version and it works as expected. Would be
nice if someone could test the nxp version to ensure no regressions has
been introduced (I don't have such hardware here).

On Wed, Jan 20, 2016 at 04:43:31PM +0100, Marc Kleine-Budde wrote:
> From: Damien Riegel <damien.riegel@savoirfairelinux.com>
> 
> Technologic Systems provides an IP compatible with the SJA1000,
> instantiated in an FPGA. Because of some bus widths issue, access to
> registers is made through a "window" that works like this:
> 
>     base + 0x0: address to read/write
>     base + 0x2: 8-bit register value
> 
> This commit adds a new compatible device, "technologic,sja1000", with
> read and write functions using the window mechanism.
> 
> Signed-off-by: Damien Riegel <damien.riegel@savoirfairelinux.com>
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>

Tested-by: Damien Riegel <damien.riegel@savoirfairelinux.com>

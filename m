From: Dong Aisheng <b29396@freescale.com>
Subject: Re: [PATCH 5/7] can: clear ctrlmode when close candev
Date: Tue, 4 Nov 2014 16:27:08 +0800
Message-ID: <20141104082707.GB8060@shlinux1.ap.freescale.net>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com>
 <1414579527-31100-5-git-send-email-b29396@freescale.com>
 <5457E9DA.6090702@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-can@vger.kernel.org>, <wg@grandegger.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<socketcan@hartkopp.net>, <linux-arm-kernel@lists.infradead.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5457E9DA.6090702@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 03, 2014 at 09:47:22PM +0100, Marc Kleine-Budde wrote:
> On 10/29/2014 11:45 AM, Dong Aisheng wrote:
> > Currently priv->ctrlmode is not cleared when close_candev, so next time
> > the driver will still use this value to set controller even user
> > does not set any ctrl mode.
> > e.g.
> > Step 1. ip link set can0 up type can0 bitrate 1000000 loopback on
> > Controller will be in loopback mode
> > Step 2. ip link set can0 down
> > Step 3. ip link set can0 up type can0 bitrate 1000000
> > Controller will still be set to loopback mode in driver due to saved
> > priv->ctrlmode.
> > 
> > This patch clears priv->ctrlmode when the CAN interface is closed,
> > and set it to correct mode according to next user setting.
> > 
> > Signed-off-by: Dong Aisheng <b29396@freescale.com>
> 
> NACK, as discussed with Oliver.
> 

Okay, i'm fine with it.

Regards
Dong Aisheng

> Marc
> 
> -- 
> Pengutronix e.K.                  | Marc Kleine-Budde           |
> Industrial Linux Solutions        | Phone: +49-231-2826-924     |
> Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
> Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
> 



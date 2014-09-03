From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] v2 fec_main iMX6Q DMA-API: device driver tries to free
	DMA memory it has not allocated
Date: Wed, 3 Sep 2014 14:38:05 +0100
Message-ID: <20140903133805.GZ30401@n2100.arm.linux.org.uk>
References: <1409746850-30850-1-git-send-email-moon.linux@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Nimrod Andy <B38611@freescale.com>,
	Frank Li <frank.li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, fugang.duan@freescale.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Anand Moon <moon.linux@yahoo.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1409746850-30850-1-git-send-email-moon.linux@yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 03, 2014 at 05:50:50PM +0530, Anand Moon wrote:
> Check was added to check dma address should not be 0x0000000000000000
> before unmap the dma.
>  v1: remove unnecessary of bdp->cbd_bufaddr as suggested
>  by  Andy <fugang.duan@freescale.com>

I still have a whole pile of commits, one of them cleans up the handling
of this stuff.  Please hold off on this for the time being until I can
dig out the appropriate commit.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.

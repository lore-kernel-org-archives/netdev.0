From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 0/7] net: mvneta: Switch to per-CPU irq and make
 rxq_def useful
Date: Wed, 30 Sep 2015 16:53:52 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1509301650150.4500@nanos>
References: <1443197378-30717-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jason Cooper <jason@lakedaemon.net>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Willy Tarreau <w@1wt.eu>, linux-arm-kernel@lists.infradead.org
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443197378-30717-1-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 25 Sep 2015, Gregory CLEMENT wrote:
> I also reorganized the series, the 3 first patches should go through
> the irq subsystem, whereas the 4 others should go to the network
> subsystem.
> 
> However, there is a runtime dependency between the two parts. Patch 5
> depend on the patch 3 to be able to use the percpu irq.

The first 3 are good to go from my side. To avoid merge window
dependencies, I'll create a branch irq/for-net with these 3 patches
and merge that into irq/core.

So if the network folks want to pick up the rest, they can merge in
that branch as well.

Thanks,

	tglx

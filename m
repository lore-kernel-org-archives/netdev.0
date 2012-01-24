From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] stmmac patches
Date: Tue, 24 Jan 2012 15:43:11 -0500 (EST)
Message-ID: <20120124.154311.1857537203481263793.davem@davemloft.net>
References: <cover.1327394750.git.rubini@gnudd.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, peppe.cavallaro@st.com,
	netdev@vger.kernel.org, giancarlo.asnaghi@st.com
To: rubini@gnudd.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1327394750.git.rubini@gnudd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alessandro Rubini <rubini@gnudd.com>
Date: Tue, 24 Jan 2012 10:08:45 +0100

> The following three patches add support for the STA2X11 device in the
> stmmac driver. The device is a PCI-e bridge, so I need just to
> add my identifiers.  The identifiers being added are already in pci_ids
> of linux-next.

This patch is fine.

> The second patch is a cleanup, already acked by both authors.

I'm not applying this, instead if you want to make changes in this
area then fix this driver so that it can properly support multiple
device instances.

I can't even imagine ever writing a driver where from the start
it can handle only one device instance, this is pure insanity
especially for a PCI device driver.

> As for the third, I noted that there is "#ifndef MODULE" adding
> __setup directives, but the module parameters already work, and I
> successfully use stmmac.phy_id=1 to boot my system, so the __setup
> adre just duplicates. This has not been acked by Giuseppe Cavallaro
> but I offer it here nonetheless.

You're breaking things for anyone using 'stmmaceth='.  So I'm not
applying this patch either.

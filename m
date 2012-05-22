From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 5/5] netdev/phy: Add driver for Cortina cs4321 quad 10G
 PHY.
Date: Tue, 22 May 2012 19:50:33 +0100
Message-ID: <20120522185032.GR4038@decadent.org.uk>
References: <1337709592-23347-1-git-send-email-ddaney.cavm@gmail.com>
 <1337709592-23347-6-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree-discuss@lists.ozlabs.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
	Andy Fleming <afleming@freescale.com>,
	David Daney <david.daney@cavium.com>
To: David Daney <ddaney.cavm@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1337709592-23347-6-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 22, 2012 at 10:59:52AM -0700, David Daney wrote:
[...]
> --- /dev/null
> +++ b/drivers/net/phy/cs4321-ucode.h
> @@ -0,0 +1,4378 @@
> +/*
> + *    Copyright (C) 2011 by Cortina Systems, Inc.
> + *
> + *    This program is free software; you can redistribute it and/or modify
> + *    it under the terms of the GNU General Public License as published by
> + *    the Free Software Foundation; either version 2 of the License, or
> + *    (at your option) any later version.
> + *
> + *    This program is distributed in the hope that it will be useful,
> + *    but WITHOUT ANY WARRANTY; without even the implied warranty of
> + *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + *    GNU General Public License for more details.
> + *
> + */
[...]

So where's the real source code for it?

If you won't (or can't) provide source code for the microcode then it
should instead be submitted to linux-firmware with a binary
redistribution licence, and the driver should load it with
request_firmware().

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus

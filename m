From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] sky2: copy received packets on inefficient
 unaligned architecture
Date: Wed, 04 Apr 2012 18:14:23 -0400 (EDT)
Message-ID: <20120404.181423.349006217600228558.davem@davemloft.net>
References: <20120404114253.5f84d4c8@s6510.linuxnetplumber.net>
	<4F7CC2AC.5040309@tilera.com>
	<20120404151027.047c183b@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cmetcalf@tilera.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120404151027.047c183b@s6510.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 4 Apr 2012 15:10:27 -0700

> Modified from original patch from Chris.
> 
> The sky2 driver has to have 8 byte alignment of receive buffer
> on some chip versions. On architectures which don't support efficient
> unaligned access this doesn't work very well. The solution is to
> just copy all received packets which is what the driver already
> does for small packets.
> 
> This allows the driver to be used on the Tilera TILEmpower-Gx, since
> the tile architecture doesn't currently handle kernel unaligned accesses,
> just userspace.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Acked-by: Chris Metcalf <cmetcalf@tilera.com>

Applied.

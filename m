From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC/PATCH] remove unneeded check in bcm43xx
Date: Mon, 10 Apr 2006 22:49:33 -0700 (PDT)
Message-ID: <20060410.224933.39567033.davem@davemloft.net>
References: <200604100607.33362.mb@bu3sch.de>
	<20060410042228.GN27596@ens-lyon.fr>
	<1144719972.19353.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benoit.boissinot@ens-lyon.org, mb@bu3sch.de,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	linux-kernel@vger.kernel.org, linville@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751233AbWDKFtt@vger.kernel.org>
To: benh@kernel.crashing.org
In-Reply-To: <1144719972.19353.24.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 11 Apr 2006 11:46:12 +1000

> But ppc64 hits the problem and at this point, there is nothing
> I can do other than either implementing a split zone allocation mecanism
> in the ppc64 architecture for the sole sake of bcm43xx (ick !) or doing
> some trick with the iommu...

I think allowing DMA mask range limiting in the IOMMU layer is going
to set a very bad precedence, just don't do it.

It's 2006, we should be way past the era of not putting the full 32
PCI DMA address bits in devices.  In this day and age it is simply
inexscusable.

Maybe we could understand chips coming out 8 years ago when a lot of
designs were transitioning from ISA to PCI, but that no longer applies
in any way today.

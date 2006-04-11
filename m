From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC/PATCH] remove unneeded check in bcm43xx
Date: Tue, 11 Apr 2006 18:05:51 +0200
Message-ID: <200604111805.52734.mb@bu3sch.de>
References: <200604100607.33362.mb@bu3sch.de> <1144719972.19353.24.camel@localhost.localdomain> <20060410.224933.39567033.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: benoit.boissinot-vYW+cPY1g1pg9hUCZPvPmw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
   bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
   linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
In-Reply-To: <20060410.224933.39567033.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

On Tuesday 11 April 2006 07:49, you wrote:
> From: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
> Date: Tue, 11 Apr 2006 11:46:12 +1000
> 
> > But ppc64 hits the problem and at this point, there is nothing
> > I can do other than either implementing a split zone allocation mecanism
> > in the ppc64 architecture for the sole sake of bcm43xx (ick !) or doing
> > some trick with the iommu...
> 
> I think allowing DMA mask range limiting in the IOMMU layer is going
> to set a very bad precedence, just don't do it.
> 
> It's 2006, we should be way past the era of not putting the full 32
> PCI DMA address bits in devices.  In this day and age it is simply
> inexscusable.

Sure, but we are in 2006 and actually _have_ at least two of those
devices, which are in usage by many people.
We can't say "vendors must fix this", because lots of devices are
out there.
It must be worked around in the kernel.

-- 
Greetings Michael.

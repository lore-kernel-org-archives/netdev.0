From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net/for-next V1 1/1] IB/ipoib: break linkage to neighbouring
 system
Date: Tue, 24 Jul 2012 09:24:25 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1207240924020.29808@router.home>
References: <50082183.5000402@mellanox.com> <alpine.DEB.2.00.1207191023130.29808@router.home> <500833D9.8000001@mellanox.com> <20120719.100850.1932622478297549573.davem@davemloft.net> <500B8FBE.4030600@mellanox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <500B8FBE.4030600-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 22 Jul 2012, Or Gerlitz wrote:

> On 7/19/2012 8:08 PM, David Miller wrote:
> > These numbers come from the IPV6 Neighbour Discovery RFCs.  IPV4 replicates
> > the Neighbour Unreachability Detection schemes of IPV6 in pretty much it's
> > entirety, and therefore takes on the same timeout et al. parameters.
>
> OK, got it. At this point, I guess we should enhance the patch to use the
> values plugged into the IPv4 arp table at the time IPoIB is loaded, with
> arp_tbl being exported its easy to achieve. This would allow users to use
> non-default values by the ipoib neigh handling logic. In a later step, we need
> to see if/how to allow ipoib to use the already existing sysctl entries, makes
> sense?

Sounds about right.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

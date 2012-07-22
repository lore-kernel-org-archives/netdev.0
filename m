From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net/for-next V1 1/1] IB/ipoib: break linkage to neighbouring
 system
Date: Sun, 22 Jul 2012 08:29:34 +0300
Message-ID: <500B8FBE.4030600@mellanox.com>
References: <50082183.5000402@mellanox.com> <alpine.DEB.2.00.1207191023130.29808@router.home> <500833D9.8000001@mellanox.com> <20120719.100850.1932622478297549573.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120719.100850.1932622478297549573.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 7/19/2012 8:08 PM, David Miller wrote:
> These numbers come from the IPV6 Neighbour Discovery RFCs.  IPV4 replicates the Neighbour Unreachability Detection schemes of IPV6 in pretty much it's entirety, and therefore takes on the same timeout et al. parameters.

OK, got it. At this point, I guess we should enhance the patch to use 
the values plugged into the IPv4 arp table at the time IPoIB is loaded, 
with arp_tbl being exported its easy to achieve. This would allow users 
to use non-default values by the ipoib neigh handling logic. In a later 
step, we need to see if/how to allow ipoib to use the already existing 
sysctl entries, makes sense?

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

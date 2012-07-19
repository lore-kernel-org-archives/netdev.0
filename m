From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net/for-next V1 1/1] IB/ipoib: break linkage to
 neighbouring system
Date: Thu, 19 Jul 2012 10:08:50 -0700 (PDT)
Message-ID: <20120719.100850.1932622478297549573.davem@davemloft.net>
References: <50082183.5000402@mellanox.com>
	<alpine.DEB.2.00.1207191023130.29808@router.home>
	<500833D9.8000001@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org, shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <500833D9.8000001-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Date: Thu, 19 Jul 2012 19:20:41 +0300

> On 7/19/2012 6:24 PM, Christoph Lameter wrote:
>> On Thu, 19 Jul 2012, Shlomo Pongartz wrote:
>>
>>> The garbage collection and stale times follow the default ipv4/6
>>> neigh.default.gc_yyy
>>> sysctl values, for example
>>>
>>> net.ipv4.neigh.default.gc_interval = 30
>>> net.ipv4.neigh.default.gc_stale_time = 60
>>>
>>> If given access to these values from IPoIB, we will be happy
>>> to integrate them into that logic
>>
>> It looks like the values are hardcoded right now.
> 
> Two points here,
> 
> 1s, they are indeed hard-coded since there's no define/enum
> that holds their default values (or maybe we should add one now?), see
> this code snippest from net/ipv4/arp.c

These numbers come from the IPV6 Neighbour Discovery RFCs.  IPV4
replicates the Neighbour Unreachability Detection schemes of IPV6 in
pretty much it's entirety, and therefore takes on the same timeout et
al. parameters.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

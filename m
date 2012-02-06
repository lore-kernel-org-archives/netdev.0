From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next V2] gro: introduce gro_mac_header_len
Date: Mon, 6 Feb 2012 19:09:33 +0200
Message-ID: <4F30094D.7050707@mellanox.com>
References: <1328545627.2220.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20120206.113145.1284864994961472499.davem@davemloft.net> <1328546834.2220.79.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20120206.115859.1384761795375582044.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120206.115859.1384761795375582044.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2/6/2012 6:58 PM, David Miller wrote:
> So if IPoIB path resolution was properly integrated into the neighbour 
> cache state machine, instead of being implemented awkwardly in the 
> device transmit path, this crap wouldn't be necessary right?


Dave, say we have integrated the path resolution into ND cache, how 
would you suggest ipoib to act for skbs for which xmit is called without 
a neighbour? specifically arp replies and multicast. I can think of at 
least another one other location where the HW address can be stored 
between hard_header and xmit - on the sbk->cb storage, which is large 
enough.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

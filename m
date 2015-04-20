From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v2 02/11] IB/addr: Pass network namespace as a parameter
Date: Mon, 20 Apr 2015 11:09:25 -0600
Message-ID: <20150420170925.GE7676@obsidianresearch.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
 <1429520622-10303-3-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1429520622-10303-3-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 20, 2015 at 12:03:33PM +0300, Haggai Eran wrote:
> +/** rdma_addr_find_smac_by_sgid() - Find the src MAC and VLAN ID for a src GID
> + * @sgid:	Source GID to find the MAC and VLAN for.
> + * @smac:	A buffer to contain the resulting MAC address.
> + * @vlan_id:	Will contain the resulting VLAN ID.
> + * @net:	Network namespace to use for the address resolution.
> + *
> + * It is the caller's responsibility to keep the network namespace alive until
> + * the function returns.
> + */
> +int rdma_addr_find_smac_by_sgid(union ib_gid *sgid, u8 *smac, u16 *vlan_id,
> +				struct net *net);

kdocs are typically placed with the body of the function, not at the
prototype.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

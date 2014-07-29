From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH v2] net: kernel-doc compliant documentation for net_device
Date: Tue, 29 Jul 2014 15:34:52 -0700
Message-ID: <53D8218C.1040309@infradead.org>
References: <1406666317-3509-1-git-send-email-karoly.kemeny@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Karoly Kemeny <karoly.kemeny@gmail.com>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1406666317-3509-1-git-send-email-karoly.kemeny@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/29/14 13:38, Karoly Kemeny wrote:
> Net_device is a vast and improtant structure, but it has no kernel-doc

                           important [fix for the commit log]

> compliant documentation. This patch extracts the comments from the structure
> to clean it up, and let the scripts extract documentation from it. I know that
> the patch is big, but it's just reordering of comments into the appropriate 
> form, and adding a few more, for the missing members.
> 
> v2: 
> Additional documentation added for some members (gflags,neigh_priv_len,
> queues_kset, uc_promisc, promiscuity, allmulti, _rx, _tx, watchdog_timer,
> rtnl_link_state, tstats, gso_max_size, gso_max_segs, num_tc, pm_qos_req).
> Cleaned up trailing whitespaces and blank lines.
> Fixed the beginning to indicate kernel-doc notation.
> 
> Signed-off-by: Karoly Kemeny <karoly.kemeny@gmail.com>
> ---
>  include/linux/netdevice.h | 378 ++++++++++++++++++++++++++++++----------------
>  1 file changed, 247 insertions(+), 131 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 66f9a04..66810e1 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1229,42 +1229,225 @@ enum netdev_priv_flags {
>  #define IFF_LIVE_ADDR_CHANGE		IFF_LIVE_ADDR_CHANGE
>  #define IFF_MACVLAN			IFF_MACVLAN
>  
> -/*
> - *	The DEVICE structure.
> - *	Actually, this whole structure is a big mistake.  It mixes I/O
> - *	data with strictly "high-level" data, and it has to know about
> - *	almost every data structure used in the INET module.
> +/**
> + *	struct net_device - The DEVICE structure.
> + *		Actually, this whole structure is a big mistake.  It mixes I/O
> + *		data with strictly "high-level" data, and it has to know about
> + *		almost every data structure used in the INET module.
> + *
> + *	@name:	This is the first field of the "visible" part of this structure
> + *		(i.e. as seen by users in the "Space.c" file).  It is the name
> + *	 	of the interface.
> + *
> + *	@name_hlist: 	Device name hash chain, please keep it close to name[]
> + *	@ifalias:	Snmp alias

			SNMP

> + *	@mem_end:	Shared memory end
> + *	@mem_start:	Shared memory start
...

> + *	@ifindex:	interface index
> + *	@iflink:	unique device indentifier

			              identifier
> + *

missing 'stats' struct here.

> + *	@rx_dropped:	dropped packets by core network,
> + *			do not use this in drivers
> + *	@tx_dropped:	dropped packets by core network,
> + *			do not use this in drivers
> + *
...

> + *	@vlan_info:	VLAN info
> + *	@dsa_ptr:	dsa specific data
> + *	@tipc_ptr:	TIPC specific data
> + *	@atalk_ptr:	AppleTalk link
> + *	@ip_ptr:	IPv4 specific data
> + *	@dn_ptr:	DECnet specific data
> + *	@ip6_ptr:	IPv6 specific data
> + *	@ax25:		AX.25 specific data

	@ax25_ptr:

> + *	@ieee80211_ptr:	IEEE 802.11 specific data, assign before registering
> + *
...

> + *
> + *	@destructor:		Called from unregister,
> + *				can be used to call free_netdev

missing np_info here.

> + *
> + * 	@nd_net:		Network namespace this network device is inside
...
>   */


-- 
~Randy

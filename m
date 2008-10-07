From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH 1/3] net: add ETH_P_FCOE for Fibre Channel over Ethernet
 (FCoE)
Date: Tue, 7 Oct 2008 07:43:45 +0300 (EEST)
Message-ID: <alpine.LRH.2.00.0810070741560.21872@netcore.fi>
References: <20081006233409.4918.82298.stgit@zyfc9ini.jf.intel.com> <20081006233918.4918.58918.stgit@zyfc9ini.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Yi Zou <yi.zou@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:35389 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750880AbYJGEoE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2008 00:44:04 -0400
In-Reply-To: <20081006233918.4918.58918.stgit@zyfc9ini.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 6 Oct 2008, Yi Zou wrote:
> include/linux/if_ether.h |    1 +
> 1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
> index 723a1c5..e5ae72a 100644
> --- a/include/linux/if_ether.h
> +++ b/include/linux/if_ether.h
> @@ -77,6 +77,7 @@
> #define ETH_P_PAE	0x888E		/* Port Access Entity (IEEE 802.1X) */
> #define ETH_P_AOE	0x88A2		/* ATA over Ethernet		*/
> #define ETH_P_TIPC	0x88CA		/* TIPC 			*/
> +#define ETH_P_FCOE	0x8906		/* Fibre Channel over Ethernet	*/

No problem with this one, but I note that some of the earlier 
codepoints are not in the numerical order, specifically these should 
be higher up in the list:

71 #define ETH_P_MPLS_UC   0x8847          /* MPLS Unicast traffic         */
72 #define ETH_P_MPLS_MC   0x8848          /* MPLS Multicast traffic       */
73 #define ETH_P_ATMMPOA   0x884c          /* MultiProtocol Over ATM       */

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings

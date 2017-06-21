From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] ipmr/ip6mr: add Netlink notifications
 on cache reports
Date: Wed, 21 Jun 2017 11:23:10 -0400 (EDT)
Message-ID: <20170621.112310.1172564089161295858.davem@davemloft.net>
References: <20170620205418.1648-1-julien@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, sharpd@cumulusnetworks.com,
        nicolas.dichtel@6wind.com
To: julien@arista.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170620205418.1648-1-julien@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julien Gomes <julien@arista.com>
Date: Tue, 20 Jun 2017 13:54:14 -0700

> Currently, all ipmr/ip6mr cache reports are sent through the
> mroute/mroute6 socket only.
> This forces the use of a single socket for mroute programming, cache
> reports and, regarding ipmr, IGMP messages without Router Alert option
> reception.
> 
> The present patches are aiming to send Netlink notifications in addition
> to the existing igmpmsg/mrt6msg to give user programs a way to handle
> cache reports in parallel with multiple sockets other than the
> mroute/mroute6 socket.
> 
> Changes in v2:
> - Changed attributes naming from {IPMRA,IP6MRA}_CACHEREPORTA_* to
>   {IPMRA,IP6MRA}_CREPORT_*
> - Improved packet data copy to handle non-linear packets in
>   ipmr/ip6mr cache report Netlink notification creation
> - Added two rtnetlink groups with restricted-binding
> - Changed cache report notified groups from RTNL_{IPV4,IPV6}_MROUTE to
>   the new restricted groups in ipmr/ip6mr
> 
> Changes in v3:
> - Put message size calculation for {igmp,mrt6}msg_netlink_event in separate
>   functions
> - Increased vif id attributes size from u8 to u32

Series applied, thanks.

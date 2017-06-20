From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] ipmr/ip6mr: add Netlink notifications
 on cache reports
Date: Tue, 20 Jun 2017 15:22:44 -0400 (EDT)
Message-ID: <20170620.152244.1055779320531168153.davem@davemloft.net>
References: <20170619204417.13230-1-julien@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, sharpd@cumulusnetworks.com,
        nicolas.dichtel@6wind.com
To: julien@arista.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170619204417.13230-1-julien@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julien Gomes <julien@arista.com>
Date: Mon, 19 Jun 2017 13:44:13 -0700

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

Please address Nikolay's feedback about interface number limits etc.

Thanks.

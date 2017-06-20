From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 4/4] ip6mr: add netlink notifications on
 mrt6msg cache reports
Date: Wed, 21 Jun 2017 00:27:42 +0300
Message-ID: <40136ce1-c270-7008-f348-e69805e56623@cumulusnetworks.com>
References: <20170620205418.1648-1-julien@arista.com>
 <20170620205418.1648-5-julien@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sharpd@cumulusnetworks.com, nicolas.dichtel@6wind.com
To: Julien Gomes <julien@arista.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170620205418.1648-5-julien@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/06/17 23:54, Julien Gomes wrote:
> Add Netlink notifications on cache reports in ip6mr, in addition to the
> existing mrt6msg sent to mroute6_sk.
> Send RTM_NEWCACHEREPORT notifications to RTNLGRP_IPV6_MROUTE_R.
> 
> MSGTYPE, MIF_ID, SRC_ADDR and DST_ADDR Netlink attributes contain the
> same data as their equivalent fields in the mrt6msg header.
> PKT attribute is the packet sent to mroute6_sk, without the added
> mrt6msg header.
> 
> Suggested-by: Ryan Halbrook <halbrook@arista.com>
> Signed-off-by: Julien Gomes <julien@arista.com>
> ---
>  include/uapi/linux/mroute6.h | 12 ++++++++
>  net/ipv6/ip6mr.c             | 71 ++++++++++++++++++++++++++++++++++++++++++--
>  2 files changed, 81 insertions(+), 2 deletions(-)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 3/4] ipmr: add netlink notifications on
 igmpmsg cache reports
Date: Wed, 21 Jun 2017 00:26:55 +0300
Message-ID: <3c9ab01a-4c6b-e86f-8de0-fbca12ac58be@cumulusnetworks.com>
References: <20170620205418.1648-1-julien@arista.com>
 <20170620205418.1648-4-julien@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sharpd@cumulusnetworks.com, nicolas.dichtel@6wind.com
To: Julien Gomes <julien@arista.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170620205418.1648-4-julien@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/06/17 23:54, Julien Gomes wrote:
> Add Netlink notifications on cache reports in ipmr, in addition to the
> existing igmpmsg sent to mroute_sk.
> Send RTM_NEWCACHEREPORT notifications to RTNLGRP_IPV4_MROUTE_R.
> 
> MSGTYPE, VIF_ID, SRC_ADDR and DST_ADDR Netlink attributes contain the
> same data as their equivalent fields in the igmpmsg header.
> PKT attribute is the packet sent to mroute_sk, without the added igmpmsg
> header.
> 
> Suggested-by: Ryan Halbrook <halbrook@arista.com>
> Signed-off-by: Julien Gomes <julien@arista.com>
> ---
>  include/uapi/linux/mroute.h | 12 ++++++++
>  net/ipv4/ipmr.c             | 69 +++++++++++++++++++++++++++++++++++++++++++--
>  2 files changed, 79 insertions(+), 2 deletions(-)
> 

Thanks,

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

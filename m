From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 2/4] rtnetlink: add restricted rtnl groups for
 ipv4 and ipv6 mroute
Date: Tue, 20 Jun 2017 11:56:03 +0300
Message-ID: <ceaf9d29-3c75-90a6-83c9-1356ac8216a5@cumulusnetworks.com>
References: <20170619204417.13230-1-julien@arista.com>
 <20170619204417.13230-3-julien@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sharpd@cumulusnetworks.com, nicolas.dichtel@6wind.com
To: Julien Gomes <julien@arista.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170619204417.13230-3-julien@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19/06/17 23:44, Julien Gomes wrote:
> Add RTNLGRP_{IPV4,IPV6}_MROUTE_R as two new restricted groups for the
> NETLINK_ROUTE family.
> Binding to these groups specifically requires CAP_NET_ADMIN to allow
> multicast of sensitive messages (e.g. mroute cache reports).
> 
> Signed-off-by: Julien Gomes <julien@arista.com>
> ---
>  include/uapi/linux/rtnetlink.h |  4 ++++
>  net/core/rtnetlink.c           | 13 +++++++++++++
>  2 files changed, 17 insertions(+)

Thanks!

Suggested-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

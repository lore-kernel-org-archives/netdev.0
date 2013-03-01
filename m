From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH v2 net-next 1/4] net: generic fdb support for drivers
 without ndo_fdb_<op>
Date: Fri, 01 Mar 2013 14:20:50 -0800
Message-ID: <513129C2.6080004@intel.com>
References: <1362151906-20993-1-git-send-email-vyasevic@redhat.com> <1362151906-20993-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:9714 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751836Ab3CAWUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Mar 2013 17:20:51 -0500
In-Reply-To: <1362151906-20993-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/1/2013 7:31 AM, Vlad Yasevich wrote:
> If the driver does not support the ndo_op use the generic
> handler for it. This should work in the majority of cases.
> Eventually the fdb_dflt_add call gets translated into a
> __dev_set_rx_mode() call which should handle hardware
> support for filtering via the IFF_UNICAST_FLT flag.
>
> Namely IFF_UNICAST_FLT indicates if the hardware can do
> unicast address filtering. If no support is available
> the device is put into promisc mode.
>
> CC: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>   include/linux/rtnetlink.h |    9 +++++
>   net/core/rtnetlink.c      |   81 +++++++++++++++++++++++++++++++++++++++++---
>   2 files changed, 84 insertions(+), 6 deletions(-)

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Feel free to carry the line forward when you submit these after net-next 
opens.

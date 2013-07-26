From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH V3 0/4] Add IPv6 support for iWARP
Date: Fri, 26 Jul 2013 10:50:30 -0500
Message-ID: <51F29AC6.7020202@opengridcomputing.com>
References: <1372934447-16556-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vipul Pandya <vipul@chelsio.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, divy@chelsio.com,
	dm@chelsio.com, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, tom@opengridcomputing.com,
	faisal.latif@intel.com, tatyana.e.nikolova@intel.com,
	akpm@linux-foundation.org, sasha.levin@oracle.com,
	hariprasad@chelsio.com, nirranjan@chelsio.com
To: roland@purestorage.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:59509 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758095Ab3GZPuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 11:50:24 -0400
In-Reply-To: <1372934447-16556-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/4/2013 5:40 AM, Vipul Pandya wrote:
> Hi All,
>
> This patch series adds IPv6 support for iWARP. It enables Chelsio's T4 and T5
> adapters to transmitt RDMA traffic over IPv6 address. It adds new apis and cpl
> messages in cxgb4 to support IPv6 operations and uses them in RDMA/cxgb4.
>
> The patch series  modifies the type of local_addr and remote_addr fields in
> struct iw_cm_id from struct sockaddr_in to struct sockaddr_storage to hold IPv6
> and IPv4 addresses uniformly. It changes the references of local_addr and
> remote_addr in RDMA/cxgb4, RDMA/cxgb3, RDMA/nes and amso drivers such that build
> failure is avoided.
>
> We would like to submit this patch series via Roland's infiniband tree for-next
> branch.
>
>

Hey Roland, is this series ready to merge?

Thanks,

Steve.

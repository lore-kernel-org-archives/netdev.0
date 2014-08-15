From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH] macvlan: Allow setting multicast filter on all macvlan
 types
Date: Fri, 15 Aug 2014 12:04:28 -0700
Message-ID: <53EE59BC.1070605@intel.com>
References: <1408122299-29632-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>, roopa@cumulusnetworks.com
To: Vladislav Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34689 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751210AbaHOTKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 15:10:17 -0400
In-Reply-To: <1408122299-29632-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2014 10:04 AM, Vladislav Yasevich wrote:
> Currently, macvlan code restricts multicast and unicast
> filter setting only to passthru devices.  As a result,
> if a guest using macvtap wants to receive multicast
> traffic, it has to set IFF_ALLMULTI or IFF_PROMISC.
> 
> This patch makes it possible to use the fdb interface
> to add multicast addresses to the filter thus allowing
> a guest to receive only targeted multicast traffic.
> 
> CC: John Fastabend <john.r.fastabend@intel.com>
> CC: Michael S. Tsirkin <mst@redhat.com>
> CC: Jason Wang <jasowang@redhat.com>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---

Acked-by: John Fastabend <john.r.fastabend@intel.com>

Looks good to me. Although I am trying to recall why
we restrict unicast addresses? It looks like an additional
check could be made to detect duplicate MAC addresses
in fdb_add and then we could support this as well. But
I might be missing why this wasn't supported originally.

Thanks,
John

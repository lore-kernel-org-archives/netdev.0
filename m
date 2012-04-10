From: Bart Van Assche <bvanassche@acm.org>
Subject: Re: [PATCH v4 0/10] skb paged fragment destructors
Date: Tue, 10 Apr 2012 15:46:54 +0000
Message-ID: <4F8455EE.8010709@acm.org>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Wei Liu <wei.liu2@citrix.com>,
	David VomLehn <dvomlehn@cisco.com>,
	xen-devel <xen-devel@lists.xen.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay03ant.iops.be ([212.53.5.218]:41172 "EHLO
	relay03ant.iops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759070Ab2DJPrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 11:47:07 -0400
In-Reply-To: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/12 14:26, Ian Campbell wrote:

> I think this is v4, but I've sort of lost count, sorry that it's taken
> me so long to get back to this stuff.
> 
> The following series makes use of the skb fragment API (which is in 3.2
> +) to add a per-paged-fragment destructor callback. This can be used by
> creators of skbs who are interested in the lifecycle of the pages
> included in that skb after they have handed it off to the network stack.


Hello Ian,

Great to see v4 of this patch series. But which kernel version has this
patch series been based on ? I've tried to apply this series on 3.4-rc2 but
apparently applying patch 09/10 failed:

patching file net/ceph/messenger.c
Hunk #1 FAILED at 851.
1 out of 1 hunk FAILED -- saving rejects to file net/ceph/messenger.c.rej

Regards,

Bart.

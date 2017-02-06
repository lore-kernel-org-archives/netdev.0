From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 0/5] XDP adjust head support for virtio
Date: Mon, 06 Feb 2017 11:37:13 -0500 (EST)
Message-ID: <20170206.113713.909254912988506474.davem@davemloft.net>
References: <20170203031251.23054.25387.stgit@john-Precision-Tower-5810>
        <20170205.173634.457797928882804290.davem@davemloft.net>
        <20170206045752-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, kubakici@wp.pl, jasowang@redhat.com,
        ast@fb.com, john.r.fastabend@intel.com, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42294 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752553AbdBFQhP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 11:37:15 -0500
In-Reply-To: <20170206045752-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 6 Feb 2017 06:39:54 +0200

> Well the point is to avoid resets completely, at the cost of extra 256 bytes
> for packets > 128 bytes on ppc (64k pages) only.
> 
> Found a volunteer so I hope to have this idea tested on ppc Tuesday.
> 
> And really all we need to know is confirm whether this:
> -#define MERGEABLE_BUFFER_MIN_ALIGN_SHIFT ((PAGE_SHIFT + 1) / 2)
> +#define MERGEABLE_BUFFER_MIN_ALIGN_SHIFT (PAGE_SHIFT / 2 + 1)
> 
> affects performance in a measureable way.
> 
> So I would rather wait another day. But the patches themselves
> look correct, from that POV.
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> 
> but I would prefer that you waited another day for a Tested-by from me too.

Ok.

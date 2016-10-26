From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Wed, 26 Oct 2016 19:36:45 +0300
Message-ID: <20161026185743-mutt-send-email-mst@kernel.org>
References: <1477109243-29520-1-git-send-email-shrijeet@gmail.com>
 <20161026155202.5d99d935@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shrijeet Mukherjee <shrijeet@gmail.com>, tom@herbertland.com,
        netdev@vger.kernel.org, shm@cumulusnetworks.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41202 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932275AbcJZQgv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Oct 2016 12:36:51 -0400
Content-Disposition: inline
In-Reply-To: <20161026155202.5d99d935@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2016 at 03:52:02PM +0200, Jesper Dangaard Brouer wrote:
> On Sat, 22 Oct 2016 04:07:23 +0000
> Shrijeet Mukherjee <shrijeet@gmail.com> wrote:
> 
> > This patch adds support for xdp ndo and also inserts the xdp program
> > call into the merged RX buffers and big buffers paths
> 
> I really appreciate you are doing this for virtio_net.
> 
> My first question is: Is the (packet) page data writable?
> (MST might be able to answer?)
> 
> As this is currently an XDP requirement[1].  

I'm not sure I understand what does writable mean.
Could you explain a bit more pls?
We do copy data into skb ATM but I plan to change that.


> 
> > * The small packet skb receive is skipped for now
> > * No TX for now
> 
> I do see more and more valid use-cases for only implementing XDP_DROP
> and not necessarily also implementing XDP_TX.  This does requires that
> we implement some kind of feature/capabilities negotiation mechanism[2].
> 
> 
> [1] https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/design/requirements.html#write-access-to-packet-data
> 
> [2] https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/design/design.html#capabilities-negotiation
> 
> -- 
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer

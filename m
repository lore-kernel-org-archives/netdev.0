From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH v5 5/6] virtio_net: add XDP_TX support
Date: Thu, 8 Dec 2016 23:18:22 +0200
Message-ID: <20161208231708-mutt-send-email-mst@kernel.org>
References: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
 <20161207201245.28121.95418.stgit@john-Precision-Tower-5810>
 <20161208080647-mutt-send-email-mst@kernel.org>
 <5849A3EE.7090603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, shm@cumulusnetworks.com, davem@davemloft.net,
        tgraf@suug.ch, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44868 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752510AbcLHVS2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 16:18:28 -0500
Content-Disposition: inline
In-Reply-To: <5849A3EE.7090603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2016 at 10:18:22AM -0800, John Fastabend wrote:
> > I guess this helps because it just slows down the guest.
> > I don't much like it ...
> 
> I left it like this copying the pattern in balloon and input drivers. I
> can change it back to the previous pattern where it is only called if
> there is no errors. It has been running fine with the old pattern now
> for an hour or so.
> 
> .John

I'd prefer internal consistency. Could be a patch on top
if this helps. I'm happy it isn't actually buggy.
Let me know whether you want to post v6 or
want me to ack this one.

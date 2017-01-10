From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net PATCH] net: virtio: cap mtu when XDP programs are running
Date: Tue, 10 Jan 2017 16:51:03 +0200
Message-ID: <20170110164654-mutt-send-email-mst@kernel.org>
References: <1caf1ffc-0f46-067e-0f0d-a93b408b4ffd@redhat.com>
 <586D458F.5050705@gmail.com>
 <068f0116-b37e-eb44-8c60-1781a9d5255e@redhat.com>
 <20170110010531-mutt-send-email-mst@kernel.org>
 <5874190B.9050505@gmail.com>
 <20170110012044-mutt-send-email-mst@kernel.org>
 <58742187.8050505@gmail.com>
 <20170110015759-mutt-send-email-mst@kernel.org>
 <9102bb4b-223a-d441-7546-8b4144d970fb@redhat.com>
 <20170110044910-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52788 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752031AbdAJOvG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 09:51:06 -0500
Content-Disposition: inline
In-Reply-To: <20170110044910-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 04:51:34AM +0200, Michael S. Tsirkin wrote:
> XDP seems to have a bunch of weird restrictions, I just
> do not like it that the logic spills out to all drivers.
> What if someone decides to extend it to two pages in the future?
> Recode it all in all drivers ...
> 
> Why can't net core enforce mtu?

And BTW limits on MTU are a problem that will have to be
addressed sooner or later, disabling offloads on the NIC
is one thing, but reconfiguring all of the network
with a lower MTU is another.


> -- 
> MST

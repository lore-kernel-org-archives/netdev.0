From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Blogpost evaluation this [PATCH v4 net-next RFC] net: Generic
 XDP
Date: Tue, 25 Apr 2017 10:28:57 +0200
Message-ID: <20170425102857.6f71c082@redhat.com>
References: <20170413.120925.2082322246776478766.davem@davemloft.net>
        <20170424162405.1183f2e7@redhat.com>
        <20170424.182643.485613135674690555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xdp-newbies@vger.kernel.org, netdev@vger.kernel.org,
        andy@greyhouse.net, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36026 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1175913AbdDYI3D (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 04:29:03 -0400
In-Reply-To: <20170424.182643.485613135674690555.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Apr 2017 18:26:43 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Mon, 24 Apr 2017 16:24:05 +0200
> 
> > I've done a very detailed evaluation of this patch, and I've created a
> > blogpost like report here:
> > 
> >  https://prototype-kernel.readthedocs.io/en/latest/blogposts/xdp25_eval_generic_xdp_tx.html  
> 
> Thanks for doing this Jesper.
> 
> > I didn't evaluate the adjust_head part, so I hope Andy is still
> > planning to validate that part?  
> 
> I was hoping he would post some results today as well.
> 
> Andy, how goes it? :)
> 
> Once the basic patch is ready and integrated in we can try to do
> xmit_more in generic XDP and see what that does for XDP_TX
> performance.

I agree, we can do xmit_more for generic-XDP later, and it should not
be that hard... basically replacing netdev_start_xmit() with
dev_hard_start_xmit() in generic_xdp_tx(), and finding some place to
store a XDP-skb-pointer (functioning as the skb-list) that will be
"flushed" like __kfree_skb_flush().

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 8/8] net/mlx5e: XDP TX xmit more
Date: Tue, 20 Sep 2016 11:26:49 +0200
Message-ID: <20160920112649.7054e28b@redhat.com>
References: <1474293539-2595-1-git-send-email-tariqt@mellanox.com>
        <1474293539-2595-9-git-send-email-tariqt@mellanox.com>
        <20160920094629.12e78a85@redhat.com>
        <0e732cab-ed54-5e09-569b-f75258e98ad4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52336 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752045AbcITJ0z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 05:26:55 -0400
In-Reply-To: <0e732cab-ed54-5e09-569b-f75258e98ad4@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2016 11:19:46 +0300
Tariq Toukan <ttoukan.linux@gmail.com> wrote:

> Hi Jesper,
> 
> On 20/09/2016 10:46 AM, Jesper Dangaard Brouer wrote:
> > On Mon, 19 Sep 2016 16:58:59 +0300
> > Tariq Toukan <tariqt@mellanox.com> wrote:
> >  
> >> From: Saeed Mahameed <saeedm@mellanox.com>
> >>
> >> Previously we rang XDP SQ doorbell on every forwarded XDP packet.
> >>
> >> Here we introduce a xmit more like mechanism that will queue up more
> >> than one packet into SQ (up to RX napi budget) w/o notifying the hardware.
> >>
> >> Once RX napi budget is consumed and we exit napi RX loop, we will
> >> flush (doorbell) all XDP looped packets in case there are such.  
> > I've already raised strong concerns with this approach on the RFC
> > patchset.  Of not really taking advantage of RX bulking.
> > Please do not ignore this!
>
> Sure. Your approach can fit with our plans to split the RX completion 
> poll loop into several stages.
> I will try it when we get there.
> 
> > If you can promise, that we/you will also try to other approach I'm
> > suggesting, then I'm fine with this patch.

I'll take the above as a promise that there are plans to work in the
direction I'm requesting. Thanks!

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

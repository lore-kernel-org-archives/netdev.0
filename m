From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net PATCH] mlx4: fix XDP_TX is acting like XDP_PASS on TX ring
 full
Date: Fri, 16 Sep 2016 22:29:43 +0200
Message-ID: <20160916222943.6a2ea073@redhat.com>
References: <20160916194645.13201.70408.stgit@firesoul>
        <1474056050.22679.75.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, tom@herbertland.com,
        bblanco@plumgrid.com, rana.shahot@gmail.com,
        "David S. Miller\" <davem@davemloft.net>, brouer@redhat.com"@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55982 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965082AbcIPU3t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 16:29:49 -0400
In-Reply-To: <1474056050.22679.75.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Sep 2016 13:00:50 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> > index 2040dad8611d..d414c67dfd12 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> > @@ -906,6 +906,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
> >  							length, tx_index,
> >  							&doorbell_pending))
> >  					goto consumed;
> > +				goto next;
> >  				break;  
> 
> Why keeping this break; then ? ;)

I'll send a V2


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

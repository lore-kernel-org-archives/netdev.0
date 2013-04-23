From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH 11/14] netlink: add RX/TX-ring support to netlink diag
Date: Tue, 23 Apr 2013 21:43:12 +0200
Message-ID: <1552844.mLkv3ugxeL@cpaasch-mac>
References: <1366217229-22705-1-git-send-email-kaber@trash.net> <3020335.4HTe7KSVvr@cpaasch-mac> <20130423.152339.1457379838723241885.davem@davemloft.net>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130423.152339.1457379838723241885.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 23 April 2013 15:23:39 David Miller wrote:
> > On Wednesday 17 April 2013 18:47:06 Patrick McHardy wrote:
> >> +       mutex_lock(&nlk->pg_vec_lock);
> >> +       ret = sk_diag_put_ring(&nlk->rx_ring, NETLINK_DIAG_RX_RING,
> >> nlskb);
> >> +       if (!ret)
> >> +               ret = sk_diag_put_ring(&nlk->tx_ring,
> >> NETLINK_DIAG_TX_RING,
> >> +                                      nlskb);
> >> +       mutex_unlock(&nlk->pg_vec_lock);
> >
> > 
> >
> > this produces a build-error, if CONFIG_NETLINK_MMAP=n:
> See:
> 
>         http://marc.info/?l=linux-netdev&m=136674481328037&w=2

Ok, I see. He was slightly quicker than me :)

-- 
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://multipath-tcp.org
UCLouvain
--

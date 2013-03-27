From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] net: switch to use
 skb_probe_transport_header()
Date: Wed, 27 Mar 2013 07:46:42 -0700
Message-ID: <1364395602.15753.7.camel@edumazet-glaptop>
References: <1364375482-7439-1-git-send-email-jasowang@redhat.com>
	 <1364375482-7439-3-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	Eric Dumazet <edumazet@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364375482-7439-3-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-03-27 at 17:11 +0800, Jason Wang wrote:
> Switch to use the new help skb_probe_transport_header() to do the l4 header
> probing for untrusted sources. For packets with partial csum, the header should
> already been set by skb_partial_csum_set().
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/macvtap.c             |    9 +--------
>  drivers/net/tun.c                 |   10 +---------
>  drivers/net/xen-netback/netback.c |   10 +---------
>  net/packet/af_packet.c            |   22 +++-------------------
>  4 files changed, 6 insertions(+), 45 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

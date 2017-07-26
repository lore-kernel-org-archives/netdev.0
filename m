From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: linux-next: Tree for Jul 26
Date: Wed, 26 Jul 2017 19:48:56 +0900
Message-ID: <20170726104856.GA5755@jagdpanzerIV.localdomain>
References: <20170726161203.1dfbcff9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Paul Moore <paul@paul-moore.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170726161203.1dfbcff9@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On (07/26/17 16:12), Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20170725:
> 
> Non-merge commits (relative to Linus' tree): 2358
>  2466 files changed, 86994 insertions(+), 44655 deletions(-)


dce4551cb2adb1ac ("udp: preserve head state for IP_CMSG_PASSSEC")
causes a build error

net/ipv4/udp.c: In function ‘__udp_queue_rcv_skb’:
net/ipv4/udp.c:1789:49: error: ‘struct sk_buff’ has no member named ‘sp’; did you mean ‘sk’?
  if (likely(IPCB(skb)->opt.optlen == 0 && !skb->sp))
                                                 ^

	-ss

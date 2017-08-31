From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] xfrm: Add support for network devices capable
 of removing the ESP trailer
Date: Thu, 31 Aug 2017 13:56:28 +0200
Message-ID: <20170831115628.GN3311@secunet.com>
References: <1504081839-22019-1-git-send-email-yossiku@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <borisp@mellanox.com>, <kliteyn@mellanox.com>
To: <yossiku@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1504081839-22019-1-git-send-email-yossiku@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2017 at 11:30:39AM +0300, yossiku@mellanox.com wrote:
> From: Yossi Kuperman <yossiku@mellanox.com>
> 
> In conjunction with crypto offload [1], removing the ESP trailer by
> hardware can potentially improve the performance by avoiding (1) a
> cache miss incurred by reading the nexthdr field and (2) the necessity
> to calculate the csum value of the trailer in order to keep skb->csum
> valid.
> 
> This patch introduces the changes to the xfrm stack and merely serves
> as an infrastructure. Subsequent patch to mlx5 driver will put this to
> a good use.
> 
> [1] https://www.mail-archive.com/netdev@vger.kernel.org/msg175733.html
> 
> Signed-off-by: Yossi Kuperman <yossiku@mellanox.com>

Applied to ipsec-next, thanks Yossi!

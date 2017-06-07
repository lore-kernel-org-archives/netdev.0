From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] ip_tunnel: fix potential issue in ip_tunnel_rcv
Date: Wed, 07 Jun 2017 07:48:13 -0700
Message-ID: <1496846893.736.41.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1496844976-15282-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496844976-15282-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-06-07 at 22:16 +0800, Haishuang Yan wrote:
> When ip_tunnel_rcv fails, the tun_dst won't be freed, so move
> skb_dst_set to begin and tun_dst would be freed by kfree_skb.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> ---

Please add the missing Fixes: tag and CC author of the patch that added
this bug, so that he has a chance to comment and avoid future similar
bugs.

Thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/2] ip_tunnel: fix potential issue in ip_tunnel_rcv
Date: Fri, 16 Jun 2017 12:02:02 -0400 (EDT)
Message-ID: <20170616.120202.12666969526527584.davem@davemloft.net>
References: <1497493770-13000-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, pshelar@ovn.org, ast@fb.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497493770-13000-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Thu, 15 Jun 2017 10:29:29 +0800

> When ip_tunnel_rcv fails, the tun_dst won't be freed, so call
> dst_release to free it in error code path.
> 
> Fixes: 2e15ea390e6f ("ip_gre: Add support to collect tunnel metadata.")
> Acked-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Pravin B Shelar <pshelar@ovn.org>
> Tested-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied.

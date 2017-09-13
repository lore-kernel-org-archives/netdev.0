From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/2] ip6_tunnel: fix ip6 tunnel lookup in collect_md
 mode
Date: Tue, 12 Sep 2017 20:45:57 -0700 (PDT)
Message-ID: <20170912.204557.891051979478318768.davem@davemloft.net>
References: <1505209677-12728-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
        <1505209677-12728-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org, ast@fb.com
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505209677-12728-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Tue, 12 Sep 2017 17:47:57 +0800

> In collect_md mode, if the tun dev is down, it still can call
> __ip6_tnl_rcv to receive on packets, and the rx statistics increase
> improperly.
> 
> When the md tunnel is down, it's not neccessary to increase RX drops
> for the tunnel device, packets would be recieved on fallback tunnel,
> and the RX drops on fallback device will be increased as expected.
> 
> Fixes: 8d79266bc48c ("ip6_tunnel: add collect_md mode to IPv6 tunnels")
> Cc: Alexei Starovoitov <ast@fb.com>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied.

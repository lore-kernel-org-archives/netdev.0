From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 2/2] ip6_tunnel: fix potential issue in __ip6_tnl_rcv
Date: Wed, 7 Jun 2017 19:49:17 -0700
Message-ID: <20170608024916.ujy5muoelj6x646i@ast-mbp>
References: <1496883476-17445-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <1496883476-17445-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "=David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@fb.com>
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1496883476-17445-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2017 at 08:57:56AM +0800, Haishuang Yan wrote:
> When __ip6_tnl_rcv fails, the tun_dst won't be freed, so move
> skb_dst_set to begin and tun_dst would be freed by kfree_skb.
> 
> CC: Alexei Starovoitov <ast@fb.com>
> Fixes: 8d79266bc48c ("ip6_tunnel: add collect_md mode to IPv6 tunnels")
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Good catch. Thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>

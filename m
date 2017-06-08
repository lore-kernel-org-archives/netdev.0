From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v3 1/2] ip_tunnel: fix potential issue in ip_tunnel_rcv
Date: Thu, 8 Jun 2017 14:47:59 -0700
Message-ID: <CAOrHB_A8yBEwuBvqKBK3qX8Jgrm2ZnH0_6932r52Dnv0xWt_fg@mail.gmail.com>
References: <1496896364-27153-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "=David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496896364-27153-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 7, 2017 at 9:32 PM, Haishuang Yan
<yanhaishuang@cmss.chinamobile.com> wrote:
> When ip_tunnel_rcv fails, the tun_dst won't be freed, so call
> dst_release to free it in error code path.
>
> CC: Pravin B Shelar <pshelar@nicira.com>
> Fixes: 2e15ea390e6f ("ip_gre: Add support to collect tunnel metadata.")
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>
> ---
> Changes in v2:
>   - Add the the missing Fixes information
> Changes in v3:
>   - Free tun_dst from error code path
> ---

Acked-by: Pravin B Shelar <pshelar@ovn.org>

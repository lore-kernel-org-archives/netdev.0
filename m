From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v4 1/2] ip_tunnel: fix ip tunnel lookup in collect_md mode
Date: Tue, 12 Sep 2017 16:41:50 -0700
Message-ID: <CAOrHB_CqcxxLxojk3Gy9JU=fQq5MFUOsSgy3+U941A0VONQzMA@mail.gmail.com>
References: <1505209677-12728-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505209677-12728-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 12, 2017 at 2:47 AM, Haishuang Yan
<yanhaishuang@cmss.chinamobile.com> wrote:
> In collect_md mode, if the tun dev is down, it still can call
> ip_tunnel_rcv to receive on packets, and the rx statistics increase
> improperly.
>
> When the md tunnel is down, it's not neccessary to increase RX drops
> for the tunnel device, packets would be recieved on fallback tunnel,
> and the RX drops on fallback device will be increased as expected.
>
> Fixes: 2e15ea390e6f ("ip_gre: Add support to collect tunnel metadata.")
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Acked-by: Pravin B Shelar <pshelar@ovn.org>

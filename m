From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: add CHECKSUM target
Date: Fri, 9 Jul 2010 11:56:26 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007091154120.7235@obet.zrqbmnf.qr>
References: <20100708222913.GA4475@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, herbert.xu@redhat.com, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100708222913.GA4475@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2010-07-09 00:29, Michael S. Tsirkin wrote:
>
> include/linux/netfilter_ipv4/ipt_CHECKSUM.h |   18 +++++++
> net/ipv4/netfilter/Kconfig                  |   16 ++++++
> net/ipv4/netfilter/Makefile                 |    1 +
> net/ipv4/netfilter/ipt_CHECKSUM.c           |   72 +++++++++++++++++++++++++++

New modules should use xt.

>+static unsigned int
>+checksum_tg(struct sk_buff *skb, const struct xt_action_param *par)
>+{
>+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
>+		skb_checksum_help(skb);
>+	}

- {}

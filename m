From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ip_tunnel: enclose a code block in macro
 IS_ENABLED(CONFIG_IPV6)
Date: Mon, 23 May 2016 20:14:18 -0700
Message-ID: <1464059658.5939.40.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1464057597-3648-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464057597-3648-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-05-24 at 10:39 +0800, Haishuang Yan wrote:
> For ipv6 case, enclose the code block in macro IS_ENABLED(CONFIG_IPV6).
> 
> ---
> Changes in v2:
>   - Place the "#if IS_ENABLED" block before the "} else if
> (..) {" piece and the "#endif" before the closing brace and this
> becomes much easier to look at.

_Why_ is this patch needed ?

Please describe in the changelog what _actual_ problem you are trying to
address.

We have many points in the kernel using ipv6_get_dsfield() even if
CONFIG_IPV6=n, and it seems fine to me at least.

Thanks.

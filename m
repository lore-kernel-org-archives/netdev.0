From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch] net, ipv4: fix link error when CONFIG_IPV6 is a module
Date: Mon, 29 Apr 2013 09:43:14 +0800
Message-ID: <CAM_iQpWz-4R7qR+gNxPbYBX+5=Wbnb6uHMdoF0jjYiNvJpcBdA@mail.gmail.com>
References: <alpine.DEB.2.02.1304281407310.3194@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Rientjes <rientjes@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1304281407310.3194@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 29, 2013 at 5:08 AM, David Rientjes <rientjes@google.com> wrote:
> -#if IS_ENABLED(CONFIG_IPV6)
> +#if IS_BUILTIN(CONFIG_IPV6)

This is not a right fix. We had a right one:

[PATCH net-next v3] ipv6: Kill ipv6 dependency of icmpv6_send()
http://marc.info/?l=linux-netdev&m=136692412322576&w=2

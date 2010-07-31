From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: cookie transactions setsockopt memory leak
Date: Fri, 30 Jul 2010 23:05:24 -0700 (PDT)
Message-ID: <20100730.230524.39186905.davem@davemloft.net>
References: <AANLkTinHWJviHmhVcFQkobsgxa4-AaFUpHmd1wybiB+u@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	pekkas@netcore.fi, yoshfuji@linux-ipv6.org, eric.dumazet@gmail.com,
	ilpo.jarvinen@helsinki.fi, akpm@linux-foundation.org,
	steve@digidescorp.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, william.allen.simpson@gmail.com
To: dp@highloadlab.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinHWJviHmhVcFQkobsgxa4-AaFUpHmd1wybiB+u@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Popov <dp@highloadlab.com>
Date: Thu, 29 Jul 2010 15:59:36 +0400

> From: Dmitry Popov <dp@highloadlab.com>
> 
> There is a bug in do_tcp_setsockopt(net/ipv4/tcp.c),
> TCP_COOKIE_TRANSACTIONS case.
> In some cases (when tp->cookie_values == NULL) new tcp_cookie_values
> structure can be allocated (at cvp), but not bound to
> tp->cookie_values. So a memory leak occurs.
> 
> Signed-off-by: Dmitry Popov <dp@highloadlab.com>

Applied and queued up for -stable, thanks Dmitry.

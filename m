From: David Miller <davem@davemloft.net>
Subject: Re: [PATHC] net: napi_reuse_skb() should check pfmemalloc
Date: Sun, 26 Oct 2014 22:47:50 -0400 (EDT)
Message-ID: <20141026.224750.69834261666003874.davem@davemloft.net>
References: <1413992737.9031.1.camel@edumazet-glaptop2.roam.corp.google.com>
	<1811414063272@webcorp02e.yandex-team.ru>
	<1414071030.2094.46.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: klamm@yandex-team.ru, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	tushar.n.dave@intel.com, sassmann@kpanic.de,
	gregkh@linuxfoundation.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414071030.2094.46.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Oct 2014 06:30:30 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Do not reuse skb if it was pfmemalloc tainted, otherwise
> future frame might be dropped anyway.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.

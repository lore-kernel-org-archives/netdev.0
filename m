From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 6/9] tproxy: added IPv6 socket lookup function to
 nf_tproxy_core
Date: Thu, 21 Oct 2010 10:42:05 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1010211040250.22922@obet.zrqbmnf.qr>
References: <20101020112118.6260.31618.stgit@este.odu> <20101020112118.6260.89471.stgit@este.odu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101020112118.6260.89471.stgit@este.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2010-10-20 13:21, KOVACS Krisztian wrote:
>+
>+	pr_debug("tproxy socket lookup: proto %u %pI6:%u -> %pI6:%u, lookup type: %d, sock %p\n",
>+		 protocol, saddr, ntohs(sport), daddr, ntohs(dport), lookup_type, sk);

Shorts should preferably be used with %hd/%hu.

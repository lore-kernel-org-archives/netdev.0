From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [PATCH 6/9] tproxy: added IPv6 socket lookup function to
 nf_tproxy_core
Date: Thu, 21 Oct 2010 11:48:49 +0200
Message-ID: <1287654529.13326.23.camel@este.odu>
References: <20101020112118.6260.31618.stgit@este.odu>
	 <20101020112118.6260.89471.stgit@este.odu>
	 <alpine.LNX.2.01.1010211040250.22922@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1010211040250.22922@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, 2010-10-21 at 10:42 +0200, Jan Engelhardt wrote:
> On Wednesday 2010-10-20 13:21, KOVACS Krisztian wrote:
> >+
> >+	pr_debug("tproxy socket lookup: proto %u %pI6:%u -> %pI6:%u, lookup type: %d, sock %p\n",
> >+		 protocol, saddr, ntohs(sport), daddr, ntohs(dport), lookup_type, sk);
> 
> Shorts should preferably be used with %hd/%hu.

Fixed, thanks Jan.

--KK



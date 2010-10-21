From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 4/9] tproxy: added tproxy sockopt interface in the IPV6
 layer
Date: Thu, 21 Oct 2010 10:39:02 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1010211037520.22922@obet.zrqbmnf.qr>
References: <20101020112118.6260.31618.stgit@este.odu> <20101020112118.6260.78508.stgit@este.odu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101020112118.6260.78508.stgit@este.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 2010-10-20 13:21, KOVACS Krisztian wrote:

>@@ -268,6 +268,10 @@ struct in6_flowlabel_req {
> /* RFC5082: Generalized Ttl Security Mechanism */
> #define IPV6_MINHOPCOUNT		73
> 
>+#define IPV6_ORIGDSTADDR        74
>+#define IPV6_RECVORIGDSTADDR    IPV6_ORIGDSTADDR
>+#define IPV6_TRANSPARENT        75
>+

Why do we actually need two names for the same thing?

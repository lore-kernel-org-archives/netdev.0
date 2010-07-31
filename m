From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 2/2] nf_nat: don't check if the tuple is unique when
 there isn't any other choice
Date: Sat, 31 Jul 2010 16:03:45 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007311603010.32289@obet.zrqbmnf.qr>
References: <1280542939-14606-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280542939-14606-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Saturday 2010-07-31 04:22, Changli Gao wrote:
>+++ b/net/ipv4/netfilter/nf_nat_proto_common.c
>@@ -81,9 +81,9 @@ void nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
> 	else
> 		off = *rover;
> 
>-	for (i = 0; i < range_size; i++, off++) {
>+	for (i = 0; 1; off++) {

The 1 looks strange. It's more common to express this without
a condition, as in (i = 0; ; ++off).


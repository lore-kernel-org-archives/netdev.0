From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: netfilter 00/31: netfilter update
Date: Fri, 12 Jun 2009 03:48:57 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0906120347200.28404@fbirervta.pbzchgretzou.qr>
References: <20090611.161910.109357779.davem@davemloft.net> <20090611.164047.74924409.davem@davemloft.net> <4A31978A.3040300@trash.net> <20090611.165041.201036582.davem@davemloft.net> <4A31B0CD.40300@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:45197 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbZFLBs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 21:48:56 -0400
In-Reply-To: <4A31B0CD.40300@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Friday 2009-06-12 03:35, Patrick McHardy wrote:
>@@ -418,7 +418,7 @@ ipt_do_table(struct sk_buff *skb,
> #endif
> 		verdict = t->u.kernel.target->target(skb, &tgpar);
> #ifdef CONFIG_NETFILTER_DEBUG
>-		if (comefrom != 0xeeeeeeec && verdict == IPT_CONTINUE) {
>+		if (tb_comefrom != 0xeeeeeeec && verdict == IPT_CONTINUE) {
> 			printk("Target %s reentered!\n",
> 			       t->u.kernel.target->name);
> 			verdict = NF_DROP;

Apologies; must have been an oversight on my behalf -- since the ipv6
code did indeed receive the comefrom => tb_comefrom transform in the
debug half.

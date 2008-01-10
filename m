From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6.23+] ingress classify to [nf]mark
Date: Thu, 10 Jan 2008 18:29:55 +0100
Message-ID: <47865613.1000902@trash.net>
References: <47866C69.3080904@bspu.unibel.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mahatma@eu.by
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60063 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756729AbYAJReU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 12:34:20 -0500
In-Reply-To: <47866C69.3080904@bspu.unibel.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dzianis Kahanovich wrote:
> --- linux-2.6.23-gentoo-r2/net/sched/sch_ingress.c
> +++ linux-2.6.23-gentoo-r2.fixed/net/sched/sch_ingress.c
> @@ -161,2 +161,5 @@
>              skb->tc_index = TC_H_MIN(res.classid);
> +#ifdef CONFIG_NET_SCH_INGRESS_TC2MARK
> +            skb->mark = 
> (skb->mark&(res.classid>>16))|TC_H_MIN(res.classid);
> +#endif
>          default:


Behaviour like this shouldn't depend on compile-time options.


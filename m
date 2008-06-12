From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH 18/26] IPVS: Add functions for getting/creating IPv6 connections.
Date: Wed, 11 Jun 2008 21:55:41 -0400
Message-ID: <4850821D.4080707@hp.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com> <1213204329-10973-19-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	horms@verge.net.au, davem@davemloft.net, vbusam@google.com
To: "Julius R. Volz" <juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:23457 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753282AbYFLBzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 21:55:43 -0400
In-Reply-To: <1213204329-10973-19-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julius R. Volz wrote:
> +	INIT_LIST_HEAD(&cp->c_list);
> +	setup_timer(&cp->timer, ip_vs_conn_expire, (unsigned long)cp);
> +	cp->af		   = AF_INET6;
> +	cp->protocol	   = proto;
> +	cp->caddr.v6	   = *caddr;
> +	cp->cport	   = cport;
> +	cp->vaddr.v6	   = *vaddr;
> +	cp->vport	   = vport;
> +	cp->daddr.v6	   = *daddr;

ipv6_addr_copy().

-Brian

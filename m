From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH take 2] net_sched: Add qdisc __NET_XMIT_BYPASS flag
Date: Mon, 04 Aug 2008 21:35:35 +0300
Message-ID: <20080804213535.14214iqhxkx3v3so@hayate.ip6>
References: <20080731171431.GA9464@ami.dom.local>
	<4892AA16.40706@trash.net> <20080801101929.GA12735@ff.dom.local>
	<20080803.182524.240976246.davem@davemloft.net>
	<20080804062813.GA4570@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:49579 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757249AbYHDSfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 14:35:40 -0400
In-Reply-To: <20080804062813.GA4570@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting "Jarek Poplawski" <jarkao2@gmail.com>:

>
> These 2 patches aren't supposed to fix these problems:
>
> - the __NET_XMIT_STOLEN patch fixes a problem when a qdiscs passed
>   upwards NET_XMIT_SUCCESS when eg. an skb was stolen by an action,
>   to prevent treating this as dropped; then the upper qdiscs couldn't
>   tell it's not the full NET_XMIT_SUCCESS and counted it as queued,
>   which was wrong. (BTW, I especially tried to do it with minimal
>   changes in htb_enqueue() to let you apply your htb patch without
>   much editing.)
>
> - the __NET_XMIT_BYPASS actually doesn't fix any serious problem, but
>   lets to remove the mapping from dev_queue_xmit(), and BTW it passes
>   better information to upper qdiscs too.
>

This seems to also make sure that when returning 'full'  
NET_XMIT_SUCCESS, skb pointer is safe(r?) to use now.



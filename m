From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED]: sch_ingress: remove netfilter support
Date: Thu, 31 Jan 2008 16:57:37 -0800 (PST)
Message-ID: <20080131.165737.235939096.davem@davemloft.net>
References: <479F460B.2060104@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50160
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754940AbYBAA5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 19:57:16 -0500
In-Reply-To: <479F460B.2060104@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 29 Jan 2008 16:28:11 +0100

>     [NET_SCHED]: sch_ingress: remove netfilter support
>     
>     Since the old policer code is gone, TC actions are needed for policing.
>     The ingress qdisc can get packets directly from netif_receive_skb()
>     in case TC actions are enabled or through netfilter otherwise, but
>     since without TC actions there is no policer the only thing it actually
>     does is count packets.
>     
>     Remove the netfilter support and always require TC actions.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.

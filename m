From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: l2tp: Make l2tp_ip6 namespace aware
Date: Mon, 30 May 2016 00:04:11 -0700 (PDT)
Message-ID: <20160530.000411.613218510439299331.davem@davemloft.net>
References: <1464282996-9323-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	celston@katalix.com, jchapman@katalix.com
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50093 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbcE3HEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 03:04:16 -0400
In-Reply-To: <1464282996-9323-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Thu, 26 May 2016 20:16:36 +0300

> l2tp_ip6 tunnel and session lookups were still using init_net, although
> the l2tp core infrastructure already supports lookups keyed by 'net'.
> 
> As a result, l2tp_ip6_recv discarded packets for tunnels/sessions
> created in namespaces other than the init_net.
> 
> Fix, by using dev_net(skb->dev) or sock_net(sk) where appropriate.
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Applied.

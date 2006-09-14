From: Philip Craig <philipc@snapgear.com>
Subject: Re: [PATCH] EtherIP tunnel driver (RFC 3378)
Date: Thu, 14 Sep 2006 11:21:22 +1000
Message-ID: <4508AE92.1090202@snapgear.com>
References: <20060911204129.GA28929@zlug.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:4023 "EHLO
	cyberguard.com.au") by vger.kernel.org with ESMTP id S1751310AbWINBVT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 21:21:19 -0400
To: Joerg Roedel <joro-lkml@zlug.org>
In-Reply-To: <20060911204129.GA28929@zlug.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joerg Roedel wrote:
> +	 To configure tunnels an extra tool is required. You can download
> +	 it from http://zlug.fh-zwickau.de/~joro/projects/ under the
> +	 EtherIP section. If unsure, say N.

To obtain a list of tunnels, this tool calls SIOCGETTUNNEL
(SIOCDEVPRIVATE + 0) for every device in /proc/net/dev. I don't think
this is safe, but I don't have a solution for you.

Is there a reason why you have a separate tool rather than modifying
iproute2?

I don't know if you are aware of this older etherip patch by Lennert
Buytenhek: http://www.wantstofly.org/~buytenh/etherip/

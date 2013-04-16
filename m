From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH net-next v2 1/1] net: fec: Enable imx6 enet checksum acceleration.
Date: Tue, 16 Apr 2013 16:30:30 +0100
Message-ID: <516D6E96.8020708@mentor.com>
References: <y> <1366108587-3866-1-git-send-email-jim_baxter@mentor.com> <1366120231.4459.132.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:56068 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757331Ab3DPPah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 11:30:37 -0400
In-Reply-To: <1366120231.4459.132.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 16/04/13 14:50, Eric Dumazet wrote:
> 
> Unless I am missing something, NETIF_F_GRO doesn't need to be set by a
> driver.
> 
> Documentation/networking/netdev-features.txt lines 129-130
> 
> 
> 

You are right, I think that should be NETIF_F_RXCSUM instead. I will
update the patch.

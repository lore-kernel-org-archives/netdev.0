From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next-2.6] bnx2x: Remove two prefetch()
Date: Wed, 28 Apr 2010 16:14:15 +0300
Message-ID: <1272460455.30392.24.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1272018366.7895.7930.camel@edumazet-laptop>
 <20100427.150817.84390202.davem@davemloft.net>
 <1272406693.2343.26.camel@edumazet-laptop>
 <20100427.151937.62344362.davem@davemloft.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, eliezert@gmail.com,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"xiaosuo@gmail.com" <xiaosuo@gmail.com>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"therbert@google.com" <therbert@google.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4548 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752603Ab0D1NO3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Apr 2010 09:14:29 -0400
In-Reply-To: <20100427.151937.62344362.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-04-27 at 15:19 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 28 Apr 2010 00:18:13 +0200
> 
> > [PATCH net-next-2.6] bnx2x: Remove two prefetch()
> > 
> > 1) Even on 64bit arches, sizeof(struct sk_buff) < 256
> > 2) No need to prefetch same pointer twice.
> > 
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > CC: Eilon Greenstein <eilong@broadcom.com>
> 
> Eilon please review and ACK/NACK

Vlad ran few benchmarks, and we couldn't find any justification for
those prefetch calls. After consulting with Eliezer Tamir (the original
author) we are glad to Ack this patch.

Thanks Eric!
Acked-by: <eilong@broadcom.com>




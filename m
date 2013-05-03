From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: Fix TCPv6 segmentation.
Date: Fri, 03 May 2013 16:11:57 -0400 (EDT)
Message-ID: <20130503.161157.573870812499890662.davem@davemloft.net>
References: <1367547422-18122-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933831Ab3ECUL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 16:11:59 -0400
In-Reply-To: <1367547422-18122-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu,  2 May 2013 19:17:02 -0700

> This patch set correct skb->protocol so that inner packet can
> lookup correct gso handler.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
> Same issue exist in 3.8.

Applied and queued up for -stable.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnxt_en: Fix compile warnings when
 CONFIG_INET is not set.
Date: Sun, 25 Oct 2015 22:39:00 -0700 (PDT)
Message-ID: <20151025.223900.1243223160614797552.davem@davemloft.net>
References: <1445826477-24881-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbbJZFW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 01:22:26 -0400
In-Reply-To: <1445826477-24881-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>
Date: Sun, 25 Oct 2015 22:27:57 -0400

> bnxt_gro_skb() has unused variables when CONFIG_INET is not set.  We
> really cannot support hardware GRO if CONFIG_INET is not set, so
> compile out bnxt_gro_skb() completely and define BNXT_FLAG_GRO to be 0
> if CONFIG_INET is not set.  This will effectively always disable
> hardware GRO if CONFIG_INET is not set.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/19 v2] net: bnx2x: Change variable type to bool
Date: Thu, 03 Oct 2013 15:41:30 -0400 (EDT)
Message-ID: <20131003.154130.845428835683264790.davem@davemloft.net>
References: <1380716391-20214-1-git-send-email-peter.senna@gmail.com>
	<1380716391-20214-2-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: peter.senna@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893Ab3JCTlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 15:41:32 -0400
In-Reply-To: <1380716391-20214-2-git-send-email-peter.senna@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Senna Tschudin <peter.senna@gmail.com>
Date: Wed,  2 Oct 2013 14:19:49 +0200

> The variable rc is only assigned the values true and false.
> The function bnx2x_prev_is_path_marked already returns bool.
> Change rc type to bool.
> 
> The simplified semantic patch that find this problem is as
> follows (http://coccinelle.lip6.fr/):
> 
> @exists@
> type T;
> identifier b;
> @@
> - T
> + bool
>   b = ...;
>   ... when any
>   b = \(true\|false\)
> 
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

Applied.

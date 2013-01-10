From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: align define usage to satisfy static
 checkers
Date: Thu, 10 Jan 2013 14:40:20 -0800 (PST)
Message-ID: <20130110.144020.1382112885747043594.davem@davemloft.net>
References: <1357751075-23112-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34623 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753424Ab3AJWkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 17:40:21 -0500
In-Reply-To: <1357751075-23112-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ariel Elior" <ariele@broadcom.com>
Date: Wed, 9 Jan 2013 19:04:35 +0200

> Static checkers complained that the E1H_FUNC_MAX define is used
> incorrectly in bnx2x_pretend_func(). The complaint was justified,
> although its not a real bug, as the first part of the conditional
> protects us in this case (a real bug would happen if a VF tried to
> use the pretend func, but there are no VFs in E1H chips).
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>

Applied.

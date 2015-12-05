From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/7] cxgb4: prevent simultaneous execution of
 service_ofldq()
Date: Sat, 05 Dec 2015 17:54:06 -0500 (EST)
Message-ID: <20151205.175406.2276753550050897246.davem@davemloft.net>
References: <1449218891-7819-1-git-send-email-hariprasad@chelsio.com>
	<1449218891-7819-5-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39397 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276AbbLEWyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 17:54:09 -0500
In-Reply-To: <1449218891-7819-5-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Fri,  4 Dec 2015 14:18:08 +0530

> +	u8 service_ofldq_running;   /* service_ofldq() is processing sendq */

Please use 'bool' and 'true'/'false'.

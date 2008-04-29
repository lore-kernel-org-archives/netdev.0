From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bridge: fix error handling in br_add_if()
Date: Tue, 29 Apr 2008 03:17:50 -0700 (PDT)
Message-ID: <20080429.031750.252450213.davem@davemloft.net>
References: <20080428172925.64b88010@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, volodymyrgl@gmail.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59029
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752159AbYD2KRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 06:17:51 -0400
In-Reply-To: <20080428172925.64b88010@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 28 Apr 2008 17:29:25 -0700

> When device is added to bridge its refcnt is incremented (in new_nbp()), but if
> error occurs during further br_add_if() operations this counter is not
> decremented back. Fix it by adding dev_put() call in the error path.
> 
> Signed-off-by: Volodymyr G Lukiianyk <volodymyrgl@gmail.com>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.

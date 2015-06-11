From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: idt77105: Use setup_timer
Date: Wed, 10 Jun 2015 22:46:47 -0700 (PDT)
Message-ID: <20150610.224647.1544829601803967624.davem@davemloft.net>
References: <20150610054005.GA12228@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: vthakkar1994@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58177 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbbFKFqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 01:46:47 -0400
In-Reply-To: <20150610054005.GA12228@vaishali-Ideapad-Z570>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vaishali Thakkar <vthakkar1994@gmail.com>
Date: Wed, 10 Jun 2015 11:10:05 +0530

> Use the timer API function setup_timer instead of structure field
> assignments to initialize a timer.
> 
> A simplified version of the Coccinelle semantic patch that performs
> this transformation is as follows:
> 
> @change@
> expression e1, e2, a;
> @@
> 
> -init_timer(&e1);
> +setup_timer(&e1, a, 0UL);
> ... when != a = e2
> -e1.function = a;
> 
> Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>

Applied to net-next, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/4] net: bcmgenet: bcmgenet_init_tx_ring()
 cleanup
Date: Sun, 04 Jan 2015 23:46:33 -0500 (EST)
Message-ID: <20150104.234633.1102329264651728598.davem@davemloft.net>
References: <20150104074523.5CA9C22034C@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46795 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873AbbAEEqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 23:46:35 -0500
In-Reply-To: <20150104074523.5CA9C22034C@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Sat,  3 Jan 2015 23:45:23 -0800 (PST)

> Signed-off-by: Petri Gynther <pgynther@google.com>

I'm not applying patches like this with not even a minor
explanation of what kind of cleanups are happening.

> -	/* Disable rate control for now */
>  	bcmgenet_tdma_ring_writel(priv, index, flow_period_val,
>  				  TDMA_FLOW_PERIOD);

And I think this comment, and the others you are removing are
absolutely appropriate and should not be removed.

Also, what value is there in renaming the function argument
'write_ptr' to 'start_ptr'?  I think both names are equally
clear.

You have to provide explanations and justifications in the commit log
message of your changes.

I'm not applying this series, sorry.

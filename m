From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: reduce RECURSION_LIMIT to 8
Date: Sun, 10 Jan 2016 17:59:03 -0500 (EST)
Message-ID: <20160110.175903.128469004176677319.davem@davemloft.net>
References: <1452188453-5523-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755481AbcAJW7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 17:59:05 -0500
In-Reply-To: <1452188453-5523-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu,  7 Jan 2016 18:40:53 +0100

> This patch tries to be conservative and reduces the limit to 8
> without further measurements. It seems ovs uses the stack more than
> other parts of the networking stack - I couldn't bring the system
> down with a non-ovs tunneling setup.

Can we figure out why OVS sucks so much wrt. stack usage instead?

I'd rather not paper over something like this, especially when it's
OVS which I'm completely not in the mood to specially cater for in
any way, shape, or form.

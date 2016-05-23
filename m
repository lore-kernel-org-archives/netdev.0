From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] fou: avoid using sk_user_data before it is
 initialised
Date: Mon, 23 May 2016 13:59:51 -0700 (PDT)
Message-ID: <20160523.135951.575984351254086980.davem@davemloft.net>
References: <1463723837-9098-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com,
	xiyou.wangcong@gmail.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50231 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234AbcEWU7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 16:59:52 -0400
In-Reply-To: <1463723837-9098-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Fri, 20 May 2016 14:57:17 +0900

> During initialisation sk->sk_user_data should not be used before
> it is initialised.
> 
> Found by bisection after noticing the following:
 ...
> Fixes: d92283e338f6 ("fou: change to use UDP socket GRO")
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
> v2
> * Updated implementation to simply access fou->protocol directly
>   as suggested by Tom Herbert and Cong Want

I think this was resolved in another way meanwhile.  If a fix is still
needed, please respin.

Thanks!

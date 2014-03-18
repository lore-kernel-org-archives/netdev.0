From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2014-03-18
Date: Tue, 18 Mar 2014 12:43:14 -0400 (EDT)
Message-ID: <20140318.124314.498188308783662754.davem@davemloft.net>
References: <1395128583-26274-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52922 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755655AbaCRQnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 12:43:20 -0400
In-Reply-To: <1395128583-26274-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 18 Mar 2014 08:43:01 +0100

> 1) Fix a sleep in atomic when pfkey_sadb2xfrm_user_sec_ctx()
>    is called from pfkey_compile_policy().
>    Fix from Nikolay Aleksandrov.
> 
> 2) security_xfrm_policy_alloc() can be called in process and atomic
>    context. Add an argument to let the callers choose the appropriate
>    way. Fix from Nikolay Aleksandrov.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.

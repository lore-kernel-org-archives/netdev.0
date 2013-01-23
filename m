From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2013-01-23
Date: Wed, 23 Jan 2013 14:00:58 -0500 (EST)
Message-ID: <20130123.140058.1653306473705960117.davem@davemloft.net>
References: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41200 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447Ab3AWTBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 14:01:01 -0500
In-Reply-To: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 23 Jan 2013 09:18:56 +0100

> 1) Add a statistic counter for invalid output states and
>    remove a superfluous state valid check, from Li RongQing.
> 
> 2) Probe for asynchronous block ciphers instead of synchronous block
>    ciphers to make the asynchronous variants available even if no
>    synchronous block ciphers are found, from Jussi Kivilinna.
> 
> 3) Make rfc3686 asynchronous block cipher and make use of
>    the new asynchronous variant, from Jussi Kivilinna.
> 
> 4) Replace some rwlocks by rcu, from Cong Wang.
> 
> 5) Remove some unused defines.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.

I hope Herbert is ok with the small crypto bits going in this way,
since they really are IPSEC specific.

Thanks.

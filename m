From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2013-12-19
Date: Thu, 19 Dec 2013 18:38:04 -0500 (EST)
Message-ID: <20131219.183804.1892402616200195799.davem@davemloft.net>
References: <1387435005-8987-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36759 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756258Ab3LSXiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 18:38:05 -0500
In-Reply-To: <1387435005-8987-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 19 Dec 2013 07:36:37 +0100

> 1) Use the user supplied policy index instead of a generated one
>    if present. From Fan Du.
> 
> 2) Make xfrm migration namespace aware. From Fan Du.
> 
> 3) Make the xfrm state and policy locks namespace aware. From Fan Du.
> 
> 4) Remove ancient sleeping when the SA is in acquire state,
>    we now queue packets to the policy instead. This replaces the
>    sleeping code.
> 
> 5) Remove FLOWI_FLAG_CAN_SLEEP. This was used to notify xfrm about the
>    posibility to sleep. The sleeping code is gone, so remove it.
> 
> 6) Check user specified spi for IPComp. Thr spi for IPcomp is only
>    16 bit wide, so check for a valid value. From Fan Du.
> 
> 7) Export verify_userspi_info to check for valid user supplied spi ranges
>    with pfkey and netlink. From Fan Du.
> 
> 8) RFC3173 states that if the total size of a compressed payload and the IPComp
>    header is not smaller than the size of the original payload, the IP datagram
>    must be sent in the original non-compressed form. These packets are dropped
>    by the inbound policy check because they are not transformed. Document the need
>    to set 'level use' for IPcomp to receive such packets anyway. From Fan Du.
> 
> Please pull or let me know if there are problems.

Pulled, thanks a lot.

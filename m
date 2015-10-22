From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2015-10-22
Date: Thu, 22 Oct 2015 07:47:12 -0700 (PDT)
Message-ID: <20151022.074712.1584968096853138087.davem@davemloft.net>
References: <1445494039-2612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54521 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756713AbbJVOar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 10:30:47 -0400
In-Reply-To: <1445494039-2612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 22 Oct 2015 08:07:15 +0200

> 1) Fix IPsec pre-encap fragmentation for GSO packets.
>    From Herbert Xu.
> 
> 2) Fix some header checks in _decode_session6.
>    We skip the header informations if the data pointer points
>    already behind the header in question for some protocols.
>    This is because we call pskb_may_pull with a negative value
>    converted to unsigened int from pskb_may_pull in this case.
>    Skipping the header informations can lead to incorrect policy
>    lookups. From Mathias Krause.
> 
> 3) Allow to change the replay threshold and expiry timer of a
>    state without having to set other attributes like replay
>    counter and byte lifetime. Changing these other attributes
>    may break the SA. From Michael Rossberg.
> 
> 4) Fix pmtu discovery for local generated packets.
>    We may fail dispatch to the inner address family.
>    As a reault, the local error handler is not called
>    and the mtu value is not reported back to userspace.
> 
> Please pull or let me know if there are problems.

Pulled, thanks a lot Steffen.

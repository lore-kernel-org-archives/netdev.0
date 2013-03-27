From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2013-03-27
Date: Wed, 27 Mar 2013 14:09:55 -0400 (EDT)
Message-ID: <20130327.140955.1821575651387808159.davem@davemloft.net>
References: <1364370068-20025-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58876 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540Ab3C0SJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 14:09:57 -0400
In-Reply-To: <1364370068-20025-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 27 Mar 2013 08:41:05 +0100

> 1) Initialize the satype field in key_notify_policy_flush(),
>    this was left uninitialized. From Nicolas Dichtel.
> 
> 2) The sequence number difference for replay notifications
>    was misscalculated on ESN sequence number wrap. We need
>    a separate replay notify function for esn.
> 
> 3) Fix an off by one in the esn replay notify function.
>    From Mathias Krause.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.

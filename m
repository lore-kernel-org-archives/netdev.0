From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2017-10-09
Date: Mon, 09 Oct 2017 09:44:50 -0700 (PDT)
Message-ID: <20171009.094450.918895915602266295.davem@davemloft.net>
References: <1507533399-29399-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51644 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754695AbdJIQov (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 12:44:51 -0400
In-Reply-To: <1507533399-29399-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 9 Oct 2017 09:16:35 +0200

> 1) Fix some error paths of the IPsec offloading API.
> 
> 2) Fix a NULL pointer dereference when IPsec is used
>    with vti. From Alexey Kodanev.
> 
> 3) Don't call xfrm_policy_cache_flush under xfrm_state_lock,
>    it triggers several locking warnings. From Artem Savkov.
> 
> Please pull or let me know if there are problems.

Pulled, thank you.

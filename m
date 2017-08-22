From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2017-08-21
Date: Tue, 22 Aug 2017 10:27:41 -0700 (PDT)
Message-ID: <20170822.102741.668612816199196412.davem@davemloft.net>
References: <1503295683-19153-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38352 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751311AbdHVR1l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 13:27:41 -0400
In-Reply-To: <1503295683-19153-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 21 Aug 2017 08:07:59 +0200

> 1) Fix memleaks when ESP takes an error path.
> 
> 2) Fix null pointer dereference when creating a sub policy
>    that matches the same outer flow as main policy does.
>    From Koichiro Den.
> 
> 3) Fix possible out-of-bound access in xfrm_migrate.
>    This patch should go to the stable trees too.
>    From Vladis Dronov.
> 
> 4) ESP can return positive and negative error values,
>    so treat both cases as an error.
> 
> Please pull or let me know if there are problems.

Pulled, thanks!

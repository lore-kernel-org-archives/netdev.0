From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net 0/4] xfrm_user info leaks
Date: Sat, 26 Aug 2017 08:58:58 -0700
Message-ID: <1503763138.12569.45.camel@perches.com>
References: <1503760140-9095-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mathias Krause <minipli@googlemail.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0180.hostedemail.com ([216.40.44.180]:41745 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751067AbdHZP7B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 11:59:01 -0400
In-Reply-To: <1503760140-9095-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-08-26 at 17:08 +0200, Mathias Krause wrote:
> Hi David, Steffen,
> 
> the following series fixes a few info leaks due to missing padding byte
> initialization in the xfrm_user netlink interface.

Were these found by inspection or by some tool?
If by tool, perhaps there are other _to_user cases?

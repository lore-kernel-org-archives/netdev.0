From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: fq_codel and skb->hash
Date: Wed, 18 Jan 2017 12:25:32 -0800
Message-ID: <1484771132.16328.1.camel@edumazet-glaptop3.roam.corp.google.com>
References: <f9913fca-da16-8620-d237-d7d8d09cced2@cradlepoint.com>
         <1484617489.13165.63.camel@edumazet-glaptop3.roam.corp.google.com>
         <1484620480.13165.65.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALx6S34ugaCqDtE=-4533mNsPgt_T0oHC1CN0-vx_uga+ihLdQ@mail.gmail.com>
         <1484666094.13165.68.camel@edumazet-glaptop3.roam.corp.google.com>
         <c8b93aa5-7e34-d6b0-aefc-6863e75402e0@cradlepoint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Andrew Collins <acollins@cradlepoint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:32826 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751642AbdARUdR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 15:33:17 -0500
Received: by mail-pg0-f66.google.com with SMTP id 194so2192169pgd.0
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 12:33:17 -0800 (PST)
In-Reply-To: <c8b93aa5-7e34-d6b0-aefc-6863e75402e0@cradlepoint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-18 at 13:21 -0700, Andrew Collins wrote:

> 
> Any interest in me spinning a real patch for this?  I agree that it'd be better
> if we were guaranteed to get a pre-encryption flow hash for any IPsec traffic,
> but in my particular case I don't care, as I control the HW and can make it give
> me a hash. :)

You certainly can send this as a patch of its own.

The pre-encryption flow hash would be a separate patch and is not a
prereq.

Thanks.

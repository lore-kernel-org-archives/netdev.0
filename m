From: Mark Salyzyn <salyzyn@android.com>
Subject: Re: refcount_t + (resend to wider audience)
Date: Fri, 28 Jul 2017 12:59:47 -0700
Message-ID: <0eba17bc-218e-c45c-5a49-9313126cd018@android.com>
References: <adaee9d9-1d35-921c-36b3-e32e6c8ce9e3@android.com>
 <20170728174117.GL2132@lunn.ch>
 <48b0c119-5277-1eca-d5d6-f2539ad3a7e8@android.com>
 <20170728.123139.1354715651678675641.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34338 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752596AbdG1T7t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 15:59:49 -0400
Received: by mail-pf0-f171.google.com with SMTP id q85so99388576pfq.1
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 12:59:49 -0700 (PDT)
In-Reply-To: <20170728.123139.1354715651678675641.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/28/2017 12:31 PM, David Miller wrote:
> Sorry, even with this explanation this -stable require is completely
> and totally inappropriate.
Puts me between a rock and a hard place trying to address kernel 
security issues. Should I instead file KASAN Use-After-Free reports on 
stable kernels here for analysis by those with more wisdom to help 
refine a more targeted fix?

For instance a dive on one of them did turn up 
89e357d83c06b6fac581c3ca7f0ee3ae7e67109e which stopped an unbounded 
refcounter by preventing multiple dump requests at the same time. But 
the other 4 KASAN reports I focused on this week, we were not so lucky.
> You guys are really pushing things way too far with this refcount_t
> stuff, seriously.
First round ever on this, I guess I am missing some turmoil, history or 
bad blood over refcount_t. Always fun to step on a landmine :-)
> NACK.

Please, guidance on where I can go from here.

Sincerely -- Mark Salyzyn

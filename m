From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 0/2] zerocopy fixes
Date: Wed, 9 Aug 2017 20:35:55 -0600
Message-ID: <ae00b9fd-6677-5b27-3841-bcfe3b27cc5f@gmail.com>
References: <20170809230944.59289-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:38657 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752216AbdHJCf5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 22:35:57 -0400
Received: by mail-pg0-f65.google.com with SMTP id 123so7308914pga.5
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 19:35:56 -0700 (PDT)
In-Reply-To: <20170809230944.59289-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/9/17 5:09 PM, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> Fix two issues introduced in the msg_zerocopy patchset.
> 
> Willem de Bruijn (2):
>   sock: fix zerocopy panic in mem accounting
>   sock: fix zerocopy_success regression with msg_zerocopy
> 
>  include/linux/skbuff.h | 9 +++++++--
>  net/core/skbuff.c      | 4 ++--
>  2 files changed, 9 insertions(+), 4 deletions(-)
> 

Fixes the problem I reported. Thanks for the quick turn around.

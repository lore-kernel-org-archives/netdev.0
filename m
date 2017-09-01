From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v5 1/2] inet_diag: allow protocols to provide
 additional data
Date: Thu, 31 Aug 2017 19:57:00 -0700
Message-ID: <1504234620.15310.19.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170831165939.5121-1-colona@arista.com>
         <20170831165939.5121-2-colona@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ivan Delalande <colona@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33943 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751127AbdIAC5C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 22:57:02 -0400
Received: by mail-pf0-f196.google.com with SMTP id v22so861247pfk.1
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 19:57:02 -0700 (PDT)
In-Reply-To: <20170831165939.5121-2-colona@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-08-31 at 09:59 -0700, Ivan Delalande wrote:
> Extend inet_diag_handler to allow individual protocols to report
> additional data on INET_DIAG_INFO through idiag_get_aux. The size
> can be dynamic and is computed by idiag_get_aux_size.
> 
> Signed-off-by: Ivan Delalande <colona@arista.com>
> ---
>  include/linux/inet_diag.h |  7 +++++++
>  net/ipv4/inet_diag.c      | 22 ++++++++++++++++++----
>  2 files changed, 25 insertions(+), 4 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

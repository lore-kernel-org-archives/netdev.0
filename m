From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: convert dst_metrics.refcnt from atomic_t
 to refcount_t
Date: Wed, 16 Aug 2017 16:16:08 -0700
Message-ID: <1502925368.4936.151.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1502911469.4936.148.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35262 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752592AbdHPXQK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 19:16:10 -0400
Received: by mail-pg0-f68.google.com with SMTP id t80so646693pgb.2
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 16:16:09 -0700 (PDT)
In-Reply-To: <1502911469.4936.148.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-08-16 at 12:24 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> refcount_t type and corresponding API should be
> used instead of atomic_t when the variable is used as
> a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free
> situations.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Please disregard. I will send a v2.

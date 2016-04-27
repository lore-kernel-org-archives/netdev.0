From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: do not block bh during prequeue processing
Date: Wed, 27 Apr 2016 12:54:20 -0700
Message-ID: <1461786860.5535.85.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461783594.5535.84.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35315 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432AbcD0TyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 15:54:23 -0400
Received: by mail-pf0-f169.google.com with SMTP id n1so26930357pfn.2
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 12:54:22 -0700 (PDT)
In-Reply-To: <1461783594.5535.84.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-27 at 11:59 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> AFAIK, nothing in current TCP stack absolutely wants BH
> being disabled once socket is owned by a thread running in
> process context.
> 
> As mentioned in my prior patch ("tcp: give prequeue mode some care"),
> processing a batch of packets might take time, better not block BH
> at all.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

Scratch that. We have some TCP_INC_STATS_BH() to take care of before.

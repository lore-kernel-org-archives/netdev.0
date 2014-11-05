From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v4] ipv6: mld: fix add_grhead skb_over_panic for
 devs with large MTUs
Date: Wed, 05 Nov 2014 12:47:29 -0800
Message-ID: <1415220449.13896.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415215658-10054-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, lw1a2.jing@gmail.com, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David L Stevens <david.stevens@oracle.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:37877 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbaKEUrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:47:32 -0500
Received: by mail-ie0-f176.google.com with SMTP id rd18so1582584iec.35
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 12:47:31 -0800 (PST)
In-Reply-To: <1415215658-10054-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-05 at 20:27 +0100, Daniel Borkmann wrote:
> It has been reported that generating an MLD listener report on
> devices with large MTUs (e.g. 9000) and a high number of IPv6
> addresses can trigger a skb_over_panic():
...
> 
> Reported-by: Wei Liu <lw1a2.jing@gmail.com>
> Fixes: 72e09ad107e7 ("ipv6: avoid high order allocations")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: David L Stevens <david.stevens@oracle.com>
> ---
>  v3->v4:
>   - Reduced noise from previous one as discussed

Thanks for your patience ;)

Acked-by: Eric Dumazet <edumazet@google.com>

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ip: zero sockaddr returned on error queue
Date: Thu, 15 Jan 2015 11:06:01 -0800
Message-ID: <1421348761.11734.83.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421345920-13994-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:59568 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbbAOTGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 14:06:04 -0500
Received: by mail-ig0-f176.google.com with SMTP id b16so14122143igk.3
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 11:06:02 -0800 (PST)
In-Reply-To: <1421345920-13994-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-15 at 13:18 -0500, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> The sockaddr is returned in IP(V6)_RECVERR as part of errhdr. That
> structure is defined and allocated on the stack as
> 
>     struct {
>             struct sock_extended_err ee;
>             struct sockaddr_in(6)    offender;
>     } errhdr;
> 
> The second part is only initialized for certain SO_EE_ORIGIN values.
> Always initialize it completely.
> 
> An MTU exceeded error on a SOCK_RAW/IPPROTO_RAW is one example that
> would return uninitialized bytes.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> 
> ----

Acked-by: Eric Dumazet <edumazet@google.com>

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/unix: don't show information about sockets from
 other namespaces
Date: Wed, 25 Oct 2017 06:37:16 -0700
Message-ID: <1508938636.30291.115.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171025071744.29095-1-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrei Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:54115 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750823AbdJYNhS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 09:37:18 -0400
Received: by mail-pf0-f180.google.com with SMTP id t188so22252442pfd.10
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 06:37:18 -0700 (PDT)
In-Reply-To: <20171025071744.29095-1-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-10-25 at 00:17 -0700, Andrei Vagin wrote:
> socket_diag shows information only about sockets from a namespace where
> a diag socket lives.
> 
> But if we request information about one unix socket, the kernel don't
> check that its netns is matched with a diag socket namespace, so any
> user can get information about any unix socket in a system. This looks
> like a bug.

Then if this a bug please provide a Fixes: tag

This way, we can know exact cutoff for backports.

I suspect that would be 

Fixes: 51d7cccf0723 ("net: make sock diag per-namespace")

Thanks.

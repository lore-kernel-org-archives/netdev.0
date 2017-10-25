From: Andrei Vagin <avagin@virtuozzo.com>
Subject: Re: [PATCH] net/unix: don't show information about sockets from
 other namespaces
Date: Wed, 25 Oct 2017 12:00:52 -0700
Message-ID: <20171025190051.GA10391@outlook.office365.com>
References: <20171025071744.29095-1-avagin@openvz.org>
 <1508938636.30291.115.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Andrei Vagin <avagin@openvz.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0114.outbound.protection.outlook.com ([104.47.1.114]:53824
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751786AbdJYTBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 15:01:09 -0400
Content-Disposition: inline
In-Reply-To: <1508938636.30291.115.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 06:37:16AM -0700, Eric Dumazet wrote:
> On Wed, 2017-10-25 at 00:17 -0700, Andrei Vagin wrote:
> > socket_diag shows information only about sockets from a namespace where
> > a diag socket lives.
> > 
> > But if we request information about one unix socket, the kernel don't
> > check that its netns is matched with a diag socket namespace, so any
> > user can get information about any unix socket in a system. This looks
> > like a bug.
> 
> Then if this a bug please provide a Fixes: tag
> 
> This way, we can know exact cutoff for backports.
> 
> I suspect that would be 
> 
> Fixes: 51d7cccf0723 ("net: make sock diag per-namespace")

Thank you, Eric. It's my fault, I forgot to add it.

> 
> Thanks.
> 
> 

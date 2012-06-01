From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: avoid tx starvation by SYNACK packets
Date: Fri, 01 Jun 2012 06:48:57 +0200
Message-ID: <1338526137.2760.1425.camel@edumazet-glaptop>
References: <1338501397.2760.1395.camel@edumazet-glaptop>
	 <20120531.190345.1754322784813248328.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hans.schillstrom@ericsson.com, netdev@vger.kernel.org,
	ncardwell@google.com, therbert@google.com, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:43437 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755121Ab2FAEtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 00:49:03 -0400
Received: by wibhn6 with SMTP id hn6so243472wib.1
        for <netdev@vger.kernel.org>; Thu, 31 May 2012 21:49:01 -0700 (PDT)
In-Reply-To: <20120531.190345.1754322784813248328.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-31 at 19:03 -0400, David Miller wrote:
> Is the net-next tree open yet?

David

Hans asked me to send a patch for testing, I sent it, and made clear it
was not a fix for current net tree.

RFC is like 'I throw a patch, I am not even 50% confident of it, please
comment and fix my bugs'. Most busy people just ignore it.

In this case, I know it really fixes a problem, but since its a day-0
one, its not meant for net tree (linux-3.5)

I don't know what's wrong with ignoring patches and consider them later
when net-next is open and various Acked-by or Tested-by signatures were
added, as done by other maintainers.

Just make clear that if a patch is not anymore listed on
http://patchwork.ozlabs.org/project/netdev/list/ , the author is
responsible for resending it with all added signatures ?

We need to exchange ideas (aka patches), even in the merge window, or if
the subtree maintainer is busy doing its own job.

Thanks

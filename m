From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: reflect SYN queue_mapping into SYNACK packets
Date: Fri, 01 Jun 2012 12:19:15 +0200
Message-ID: <1338545955.2760.1503.camel@edumazet-glaptop>
References: <1338544881.2760.1502.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Tom Herbert <therbert@google.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45298 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932899Ab2FAKTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 06:19:20 -0400
Received: by bkcji2 with SMTP id ji2so1688429bkc.19
        for <netdev@vger.kernel.org>; Fri, 01 Jun 2012 03:19:19 -0700 (PDT)
In-Reply-To: <1338544881.2760.1502.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-01 at 12:01 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 

> ---
>  net/ipv4/tcp_ipv4.c |    9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)

I'll send a v2 with the missing IPv6 part ;)

From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] netlink: autosize skb lengthes
Date: Mon, 10 Mar 2014 09:41:23 +0000
Message-ID: <20140310094123.GA2396@casper.infradead.org>
References: <1394222553.20149.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37810 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121AbaCJKBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 06:01:04 -0400
Content-Disposition: inline
In-Reply-To: <1394222553.20149.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/07/14 at 12:02pm, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> One known problem with netlink is the fact that NLMSG_GOODSIZE is
> really small on PAGE_SIZE==4096 architectures, and it is difficult
> to know in advance what buffer size is used by the application.
> 
> This patch adds an automatic learning of the size.
> 
> First netlink message will still be limited to ~4K, but if user used
> bigger buffers, then following messages will be able to use up to 16KB.
> 
> This speedups dump() operations by a large factor and should be safe
> for legacy applications.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Thomas Graf <tgraf@suug.ch>
> Google-Bug-Id: 13305844

Acked-by: Thomas Graf <tgraf@suug.ch>

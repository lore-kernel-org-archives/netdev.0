From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp/dccp: try to not exhaust
 ip_local_port_range in connect()
Date: Wed, 27 May 2015 10:47:13 -0700
Message-ID: <1432748833.4060.415.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432504175.4060.155.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150527.133157.608781400542319039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38401 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855AbbE0RrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 13:47:15 -0400
Received: by igbjd9 with SMTP id jd9so4812231igb.1
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 10:47:15 -0700 (PDT)
In-Reply-To: <20150527.133157.608781400542319039.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-27 at 13:31 -0400, David Miller wrote:

> Looks fine, applied, thanks Eric.
> 
> Arguably, we might want to emit a warning if the user sets the port
> range sysctl non-even.  But that's up to you.

Right, I guess we can do that. I'll send a followup patch.

Thanks !

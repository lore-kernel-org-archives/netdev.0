From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Early TCP socket demux
Date: Fri, 27 Jul 2012 00:12:55 +0200
Message-ID: <1343340775.2626.12078.camel@edumazet-glaptop>
References: <1343298868.2626.11348.camel@edumazet-glaptop>
	 <20120726.142903.2061753292000961457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:36143 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753144Ab2GZWNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 18:13:01 -0400
Received: by weyx8 with SMTP id x8so1672240wey.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 15:12:59 -0700 (PDT)
In-Reply-To: <20120726.142903.2061753292000961457.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-26 at 14:29 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 26 Jul 2012 12:34:28 +0200
> 
> > +	if (sysctl_ip_early_demux && !skb_dst(skb)) {
> 
> You obviously don't build ipv6 modular.
> 
> sysctl_ip_early_demux needs to be exported to modules in order
> for this to work.

Humpf....

I'll also remove the unlikely() in __inet6_lookup_skb() in v2

Thanks

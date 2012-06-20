From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 20:40:04 +0200
Message-ID: <1340217604.4604.1569.camel@edumazet-glaptop>
References: <20120619.163911.2094057156011157978.davem@davemloft.net>
	 <20120619193549.13bcffa7@s6510.linuxnetplumber.net>
	 <20120619.214657.1345825814176201681.davem@davemloft.net>
	 <1340171940.4604.799.camel@edumazet-glaptop>
	 <1340215664.2576.12.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:52733 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757638Ab2FTSkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 14:40:09 -0400
Received: by bkcji2 with SMTP id ji2so6522777bkc.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 11:40:08 -0700 (PDT)
In-Reply-To: <1340215664.2576.12.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 19:07 +0100, Ben Hutchings wrote:

> I don't know what you mean by 'have no use'.  It's enabled anyway, and I
> would expect that it's beneficial for some smaller routers.
> 

I believe vast majority of linux powered devices are more hosts,
not routers (ip_forward default value is 0 by the way)

If someone wants to tune its linux router, he probably already disables
GRO because of various issues with too big packets.

GRO adds a significant cost to forwarding path.

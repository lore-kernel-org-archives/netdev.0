From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Early TCP socket demux.
Date: Tue, 19 Jun 2012 08:28:17 +0200
Message-ID: <1340087297.7491.2458.camel@edumazet-glaptop>
References: <1340079938.7491.2172.camel@edumazet-glaptop>
	 <20120618.212721.2148947025741866390.davem@davemloft.net>
	 <1340080661.7491.2205.camel@edumazet-glaptop>
	 <20120618.230723.612232275251003129.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:54925 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785Ab2FSG2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 02:28:22 -0400
Received: by eaak11 with SMTP id k11so1822176eaa.19
        for <netdev@vger.kernel.org>; Mon, 18 Jun 2012 23:28:21 -0700 (PDT)
In-Reply-To: <20120618.230723.612232275251003129.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-18 at 23:07 -0700, David Miller wrote:

> Sure thing.
> 
> We also need to add some dst->ops->check() handling as well.

Yes, rp_filter comes to mind.

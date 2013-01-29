From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Can we replace the msleep(250) in dev.c netdev_wait_allrefs?
Date: Tue, 29 Jan 2013 12:45:30 -0800
Message-ID: <1359492330.30177.7.camel@edumazet-glaptop>
References: <51082A64.2090702@candelatech.com>
	 <1359490897.30177.4.camel@edumazet-glaptop>
	 <51082FF3.4090805@candelatech.com>
	 <20130129.153116.170658846017551064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:48050 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753659Ab3A2Upc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 15:45:32 -0500
Received: by mail-da0-f41.google.com with SMTP id e20so403617dak.0
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 12:45:32 -0800 (PST)
In-Reply-To: <20130129.153116.170658846017551064.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-29 at 15:31 -0500, David Miller wrote:
> If you only notice some time in the future that something has hung in
> this state, the original message could be lost.  Therefore, I
> definitely prefer that this thing keeps barking into the logs
> periodically.

Not sure we need the full stack, as it probably contains no useful
context / information at this point.

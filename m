From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
Date: Wed, 23 Jan 2013 17:00:42 -0800
Message-ID: <1358989242.12374.1323.camel@edumazet-glaptop>
References: <50FDADF4.3060601@candelatech.com>
	 <50FDDE35.7070806@candelatech.com>
	 <1358829606.3464.3151.camel@edumazet-glaptop>
	 <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>
	 <1358875020.3464.4006.camel@edumazet-glaptop>
	 <1358875607.3464.4020.camel@edumazet-glaptop>
	 <50FF102F.2050008@candelatech.com> <50FF4BC9.1060206@candelatech.com>
	 <5100785D.8040101@candelatech.com>
	 <1358985688.12374.1247.camel@edumazet-glaptop>
	 <51007CA8.2050105@candelatech.com>
	 <1358987031.12374.1276.camel@edumazet-glaptop>
	 <51008294.2010201@candelatech.com>
	 <1358988358.12374.1303.camel@edumazet-glaptop>
	 <51008598.4000603@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:34278 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078Ab3AXBAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 20:00:46 -0500
Received: by mail-pb0-f53.google.com with SMTP id un1so4387496pbc.12
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 17:00:46 -0800 (PST)
In-Reply-To: <51008598.4000603@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 16:51 -0800, Ben Greear wrote:

> 
> I was poking around in drivers/net/loopback.c.  Maybe it needs
> to clean up the skb_dst() before calling the rx logic in the
> loopback_xmit method?

Nope. Its ok there. We need a dst for loopback

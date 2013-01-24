From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
Date: Wed, 23 Jan 2013 21:39:21 -0800
Message-ID: <1359005961.12374.1595.camel@edumazet-glaptop>
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
	 <1358989242.12374.1323.camel@edumazet-glaptop>
	 <51008900.2010803@candelatech.com>
	 <1358989843.12374.1334.camel@edumazet-glaptop>
	 <1358991906.12374.1356.camel@edumazet-glaptop>
	 <5100B7F4.2050505@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:52745 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653Ab3AXFjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 00:39:24 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so5164242pbc.19
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 21:39:24 -0800 (PST)
In-Reply-To: <5100B7F4.2050505@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 20:26 -0800, Ben Greear wrote:

> I'll test this in the morning...one thing, maybe it's worth adding
> a WARN_ON in netif_rx() in case there are other bugs of
> this nature?

Quite frankly we should do the skb_dst_force() in netif_rx(), and remove
it from callers. This will be a net-next patch.

Thanks !

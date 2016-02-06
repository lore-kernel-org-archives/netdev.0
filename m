From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/2] tcp: fastopen: accept data/FIN present in
 SYNACK
Date: Sat, 06 Feb 2016 10:52:11 -0800
Message-ID: <1454784731.7627.329.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454389388-1506-1-git-send-email-edumazet@google.com>
	 <20160206.031302.1262914455786911151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, sara@sinodun.com,
	ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33094 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386AbcBFSwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 13:52:14 -0500
Received: by mail-pf0-f174.google.com with SMTP id w123so87134047pfb.0
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 10:52:14 -0800 (PST)
In-Reply-To: <20160206.031302.1262914455786911151.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-02-06 at 03:13 -0500, David Miller wrote:
> From: Eric Dumazet <edumazet@google.com>
> Date: Mon,  1 Feb 2016 21:03:06 -0800
> 
> > Implements RFC 7413 (TCP Fast Open) 4.2.2, accepting payload and/or FIN
> > in SYNACK messages, and prepare removal of SYN flag in tcp_recvmsg()
> 
> Series applied, thanks Eric.

It seems I missed to call tcp_fin() if a FIN flag was present.

(But then we had this issue before my patches, Yuchung, for a SYN packet
+ FIN  ?)

I will send a followup.

Thanks David.

From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: WARNING: at net/ipv4/af_inet.c:155
	inet_sock_destruct+0x122/0x13a()
Date: Thu, 13 Aug 2009 15:21:45 +0000
Message-ID: <1250176905.7289.7.camel@Maple>
References: <4A76A009.40605@wpkg.org>	<1249346282.6479.5.camel@merlyn>
	 <20090803.212007.253928711.davem@davemloft.net>
	 <4A77D2BA.3040304@gmail.com>  <4A831F69.1080703@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, mangoo@wpkg.org,
	netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f196.google.com ([209.85.216.196]:38944 "EHLO
	mail-px0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115AbZHMPVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 11:21:48 -0400
Received: by pxi34 with SMTP id 34so51839pxi.4
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2009 08:21:49 -0700 (PDT)
In-Reply-To: <4A831F69.1080703@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-12 at 16:00 -0400, Vlad Yasevich wrote:
> BTW, I've seen the same issue in 2.6.28 and 2.6.29 while doing a bunch
> of NFS-over-UDP testing.  I've seen the issue reported in 2.6.27 as well,
> but it went by ignored.  It's not easy to reproduce as it seems like it
> requires quite a bit traffic over over multiple interfaces.

I've been unable to reproduce it so far.  Has bonding always been
present in the cases you've seen, or are multiple independent interfaces
sufficient?

In the case you reported initially, openvpn was using UDP, but the peer
was dead, so there presumably wasn't much traffic from that app.  Was
there lots of NFS-over-UDP traffic also going on?

Where was the independent report on 2.6.27?

  --  John


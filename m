From: Alex Dubov <oakad@yahoo.com>
Subject: Re: Bad TCP timestamps on non-PC platforms
Date: Thu, 6 Jan 2011 17:55:34 -0800 (PST)
Message-ID: <117536.54377.qm@web37607.mail.mud.yahoo.com>
References: <1294301356.2723.73.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web37607.mail.mud.yahoo.com ([209.191.87.90]:30739 "HELO
	web37607.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755112Ab1AGBzg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 20:55:36 -0500
In-Reply-To: <1294301356.2723.73.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the awful synopsis of my problem. I never cease to amaze myself
at how bad those usually turn up. :-)

What I really meant to write is:

I have a dev board running 2.6.37-rc7. Normal kernel config, nothing fancy.
Remote machines are just usual linux boxes in constant operation (I tried
several of those).

UDP/DHCP works correctly all the time, so ethernet side is probably ok.

When tcp_timestamps are enabled, SYN packets from dev board just get
ignored by the remote side. I see them arrive in wireshark, but nothing
else happens.

When I disable tcp_timestamps on the dev board everything works.

The problem is reproducible every single time.

The only difference is the "Options" block of the SYN packets.
If timestamps are not really to blame, then it probably window scale
parameters. That's what I see on a usual dropped packet:

Options: (20 bytes)
        Maximum segment size: 1460 bytes
        SACK permitted
        Timestamps: TSval 4294893842, TSecr 0
        NOP
        Window scale: 5 (multiply by 32)



      

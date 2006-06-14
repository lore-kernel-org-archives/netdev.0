From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Wed, 14 Jun 2006 16:32:29 +0100
Message-ID: <44902C0D.1010709@andyfurniss.entadsl.com>
References: <1150278004.26181.35.camel@localhost.localdomain> <1150286766.5233.15.camel@jzny2>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>, hawk@diku.dk,
	russell-tcatm@stuart.id.au, lartc@mailman.ds9a.nl,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.ukfsn.org ([217.158.120.143]:10376 "EHLO mail.ukfsn.org")
	by vger.kernel.org with ESMTP id S964916AbWFNPby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 11:31:54 -0400
To: hadi@cyberus.ca
In-Reply-To: <1150286766.5233.15.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> I have taken linux-kernel off the list.
> 
> Russell's site is inaccessible to me (I actually think this is related
> to some DNS issues i may be having) and your masters is too long to
> spend 2 minutes and glean it; so heres a question or two for you:
> 
> - Have you tried to do a long-lived session such as a large FTP and 
> seen how far off the deviation was? That would provide some interesting
> data point.
> - To be a devil's advocate (and not claim there is no issue), where do
> you draw the line with "overhead"? 

Me and many others have run a smilar hack for years, there is also a 
userspace project still alive which does the same.

The difference is that without it I would need to sacrifice almost half 
my 288kbit atm/dsl showtime bandwidth to be sure of control.

With the modification I can run at 286kbit / 288 and know I will never 
have jitter worse than the bitrate latency of a mtu packet. The 286 
figure was choses to allow a full buffer to drain/ allow for timer 
innaccuracy etc. On a p200 with tsc, 2.6.12 it's never gone over for me 
- though talking of timers I notice on my desktop 2.6.16 I gain 2 
minutes a day now.

Andy.

From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Fri, 17 Feb 2012 11:55:02 -0500
Message-ID: <CADVnQykmt7yaENfgVAs521EX4fBjYbJqNEo2pTDuC8jmnivbuA@mail.gmail.com>
References: <1329399616.9395.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1461927.R8CTCUdqT9@localhost.localdomain>
	<CADVnQyknYYaduh4nnc27=oGofBqpExJzqA-ToXufZxbtm0xs6Q@mail.gmail.com>
	<16215291.4ftfQWZto1@localhost.localdomain>
	<1329429573.5450.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: alekcejk@googlemail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:50544 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752247Ab2BQQzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 11:55:03 -0500
Received: by qafk1 with SMTP id k1so3762247qaf.19
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2012 08:55:02 -0800 (PST)
In-Reply-To: <1329429573.5450.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And thanks, Alexey, for the detailed info.

The first tcpdump shows a SYN/SYNACK RTT of roughly 64ms, and the
second tcpdump shows a steady-state receive window of 21177* 16=338832
bytes. Together those imply that the receiver window is limiting
bandwidth to roughly (21177 * 16 bytes)/ 0.064sec ~= 5.0 Mbytes/sec.
This is pretty close to the throughput of 4.9Mbytes/sec that wget
reports, suggesting that indeed the receiver window was the limiting
factor here.

And Eric's proposed fix for this receiver window issue sounds like it
should take care of this.

neal

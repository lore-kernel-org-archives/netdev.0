From: Tom Quetchenbach <virtualphtn@gmail.com>
Subject: Re: [PATCH][BUG] tcp: advertise MSS requested by user
Date: Fri, 29 Aug 2008 09:48:03 -0700
Message-ID: <48B82843.4090707@gmail.com>
References: <48B44768.3030208@gmail.com> <20080828.024617.117112334.davem@davemloft.net> <200808281250.35006.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	lachlan.andrew@gmail.com
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:61469 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986AbYH2QsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 12:48:06 -0400
Received: by rv-out-0506.google.com with SMTP id k40so954692rvb.1
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2008 09:48:05 -0700 (PDT)
In-Reply-To: <200808281250.35006.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Best I can tell, my mailer ate this reply, so apologies if you get it twice.

>> Thanks for your patch, I'll mull over this and put in the fix
>> once I understand exactly how this got broken.

David, thanks a lot for looking into this. It will be really helpful for
our TCP benchmarking work.

> I am using, just i workaround this over iptables MSS option. You feel 
> discomfort, but most people start googling and see this trick with iptables, 
> and they use it.

In my case I don't think the iptables workaround is the right solution.
I'm working on a traffic generator (tmix, from the University of North
Carolina), that starts many simultaneous flows between two endpoints,
based on a set of "connection vectors" derived from a tcpdump. The MSS
for each flow is specified in the connection vector file on a per-flow
basis. So it's not so simple as clamping the MSS to the path MTU or
setting it based on some simple criteria like destination or port
number. I'm sure I could hack something together using iptables to
approximate what I want to do, but it seems like a bit of a mess to me.

I'm not that familiar with iptables so please correct me if I'm wrong.

Thanks
-Tom


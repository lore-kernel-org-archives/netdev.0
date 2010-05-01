From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Sat, 01 May 2010 07:29:39 -0400
Message-ID: <1272713379.14499.26.camel@bigi>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
	 <1272514176.2201.85.camel@edumazet-laptop> <1272540952.4258.161.camel@bigi>
	 <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
	 <1272545108.2222.65.camel@edumazet-laptop> <1272547061.4258.174.camel@bigi>
	 <1272547307.2222.83.camel@edumazet-laptop> <1272548258.4258.185.camel@bigi>
	 <1272548980.2222.87.camel@edumazet-laptop> <1272549408.4258.189.camel@bigi>
	 <1272573383.3969.8.camel@bigi>  <1272655814.3879.8.camel@bigi>
	 <1272660000.2230.4.camel@edumazet-laptop>  <1272672394.14499.1.camel@bigi>
	 <1272693424.2230.75.camel@edumazet-laptop>
	 <1272694442.2230.86.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:51539 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800Ab0EAL3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 07:29:43 -0400
Received: by vws19 with SMTP id 19so781827vws.19
        for <netdev@vger.kernel.org>; Sat, 01 May 2010 04:29:43 -0700 (PDT)
In-Reply-To: <1272694442.2230.86.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-05-01 at 08:14 +0200, Eric Dumazet wrote:

> BTW, using ee mask, cpu4 is not used at _all_, even for the user
> threads. Scheduler does a bad job IMHO.

I have the opposite frustration ;->
I did notice it got used. My goal was to totally avoid using it, for
simple reason it is an SMT thread that shares same core as cpu0.
In retrospect i should probably set irq affinity then to cpu0 and 4.

> Using fe mask, I get all packets (sent at 733311pps by my pktgen
> machine), and my CPU0 even has idle time !!!

I will try this next time i get the chance.

cheers,
jamal

